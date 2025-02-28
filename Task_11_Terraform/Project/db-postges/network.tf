module "network" {
  source       = "../../modules/network"
  network_name = "task-11"
  subnet_name  = "public" 
}