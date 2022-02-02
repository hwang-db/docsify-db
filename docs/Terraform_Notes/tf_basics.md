## Terraform Basics

My learning notes on Terraform, mostly summarized from the book `Terraform in Action`. I highly recommend starters to read thoroughly on Part I and II of this book. Follow hashicorp's quick starter tutorial to get started.

**Read this topic to:**
* Review hashicorp terraform exam.
* Get field experience and tips.

### Why Terraform for IaC?
* Terraform is a declarative language, you just need to describe the end goal, terraform engine will figure out all the intermediary steps and dependencies. 
* Modular design, different providers will take care of their modules, developing in terraform feels like playing lego. 
* Multi cloud, you can use terraform to easily provision resources to multiple cloud, for projects that requires e.g. Azure and AWS, terraform has this advantage over native tools like ARM / CloudFormation.  
* Easy to build your own modules and reuse in multiple projects.

## Key points

### basic commands

```
terraform init # initialize project and download providers to local
terraform plan # tf engine will compute and gets the plan of deployment
terraform apply [-auto-approve] # to deploy resources to cloud
terraform destroy [-auto-approve] # to destroy infrastructure
```

### folder structure

There are two types of design: 
- Flat design (each component having its own `.tf` file and put together in a flat folder), easiest to build and good for small projects. 
- Nested design, use modules and component reference each other, attributes are passed around using methods like `bubble up`.

You can literally write terraform in any `.tf` files without restrictions since eventually all will be appended together for engine to process. Naming of files is also not restricted. Usually variables are defined and given default values (optional) in a separate file, then you can use runtime environmental variables / secrets to give values to these defined variables. `.tfvars` file will be read and fed into variables at runtime.

```
tf_project
│   README.md
│   main.tf
|   variables.tf
|   vals.tfvars
│   component1.tf
|   component2.tf
└───modules
│   └───vm_module
│       |   main.tf
|       |   variables.tf
|       |   outputs.tf

```

In a terraform project folder, when you run any terraform command, all `.tf` files in the level (that you run command in) will be appended together and terraform engine will figure out the logic.

### provisioner blocks in resource
In a resource block, **provisioner blocks** are evaluated in sequence, example:
```
resource "null_resource" "test_null" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<-EOT
      terraform output -raw tls_private_key > ssh_private.pem
      chmod 400 ssh_private.pem
      EOT
  }
  depends_on = [
    tls_private_key.squid_ssh,
  ]
}
```
### depends_on
You can specify explicit dependency in resources using depend_on, and sometimes will save troubles when terraform destroy is executed.

### null_resource explained
In the same example snippet above, you see `null_resource`, this is a special resource that does not deploy any infra, and it's good to be used together with provisioner logics. When you want to execute some provisioner logic but don't want to deploy any infra, use `null_resource`.

### local-exec and remote-exec
Two types of provisioner blocks:
* local-exec
* remote-exec

Both allows you execute some scripts and commands, the difference is: local-exec will execute on the machine that you run terraform command. remote-exec will execute on the remote resource like vm.

### refactoring
If you see your flat design has lots of repeated code, use custom modules to put reusable code together, in a way that's easy to parameterize. Think about input/output attributes of your module, e.g. do you need a string input or a map input, consider reading in filepath so you can use json file for paramererized deployments. Module expansion is supported since tf v0.13, this greatly made modules very useful. Use `map` and `for_each` in your module expansion is the best practice.

It's very common to do refactoring in terraform, but must be careful for data loss. You definitely do not want infra to be destroyed while holding your data. Due to the design of terraform, if you do this sequence: `change config code -> tf apply` your resources like database will be destroyed and redeployed (irrelevant of using lifecycle meta or not). Instead, consider using `taint` and move state to avoid unnecessary destroy of certain resources. We will also migrate tf state in the refactoring process.

### terraform taint
Taint is to mark certain resources not to be destroyed, syntax is 
```
terraform taint [options] address
```

Address means resource address in terraform system, you can get it by: `terraform state list` to list resource address from state file.

Using `taint` we can fine-select recreation of individual resource. Tainted resources will be proposed to redeploy in the next apply.

Use `terraform untaint` to untaint resource(s).

### state migration
Terraform state files are auto generated when you run terraform apply, they contain info on what's currently deployed. 
Manual modification on state files is highly discouraged since it's prone to human error. Two proposed ways to migrate states are:
1. Use `terraform state mv SOURCE DESTINATION`
2. Delete old resources using `terraform state rm xxx` then reimporting them using `terraform import xxx`

**Method 1: native**

```
terraform state mv [options] SOURCE DESTINATION
```

**SOURCE** address is where the resource is currently located, **DESTINATION** address is where it will go after migration. You can get source address by `terraform state list`, as mentioned above. Be careful that you can move a resource or module to any address, including non-existing addresses.

This method in practice **sounds like**:
I make config code changes in .tf files
Then I use terraform state mv to subjectively modify the state file (move resource states to to-be position)
then i do tf apply and since the changed resources, for the ones with state info in correct location, will not be re-applied. (destroy and create)


**Method 2: delete and import**

By first removing states from state file and then import them into state file, we are in effect, doing a state migration. Resource imports is also the way that unmanaged resources are brought into managed resources under terraform. Actually this method is more like reimport a deliberately deleted resource into the correct resource address, to achieve the effect of a migration.

**Step 1**

Before removing state, get its resource id from:
```
terraform state show resourceA
```
Keep the `id` attribute.

**Step 2**

Remove state of resource, or modules, yes you can remove modules as well:

```
terraform state rm [options] ADDRESS
```

**Step 3**

Reimport this resource by:
```
terraform import [options] ADDRESS ID
```

**ADDRESS** is the destination resource address where you want your resource to be imported (configuration must be present for this to work), and **ID** is the unique resource ID 
ID is what you get from terraform state show resourceA -> the `id` attribute.
