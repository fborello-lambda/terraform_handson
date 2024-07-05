<h1 align="center">Terraform HandsOn</h1>


<div align="center">

```mermaid
graph LR;
    A[Compute Instance] <--> B[VPC Peering] <--> C[Cloud SQL Instance]
```
</div>

HandsOn project using GCP to provide a server that connects to a Postgres Database. The Postgres Database acn only be accessed via the server. 

Core concepts are put into practice, such as subnetworks, VPCs and even the way of connecting the DB with the VPC network created. 


# How

1. First of all, create a GCP project, then define the `project_id` variable inside a file named `terraform.tfvars`:

```hcl
project_id = "project_name"
```

2. Create a `bucket` using GCP.
3. Create the file `backend.conf`, and set with the information of the created bucket:

```sh
cp backend.conf.example backend.conf
```

4. Create an `ssh-key`, name the `.pub` as follows `./ssh_keys/gcp.pub`

5. Init Terraform's state

```sh
terraform init -backend-config=backend.conf 
```

6. Apply the changes needed to set the resources:

```sh
terraform apply
```

Now, after all resources have been initialized, ssh into the VM. After the `terraform apply` the output should be:

```
compute_instance_public_ip = "public_ip"
internal_ipv4 = "postgres_ip"
```

Use the `compute_instance_public_ip` to access the VM:

```sh
ssh -i priv_key dev@public_ip
```

Inside the VM, install `psql`:

```sh
sudo apt install postgresql-client
```

Finally, inspect the created database, it will ask for the password, the default is `password`:

```sh
psql -h "postgres_ip" -U dev -d db_policy1 -p 5432
```

Inside the postgres cli, we can type `\l` to inspect the `db_policy1` db.
