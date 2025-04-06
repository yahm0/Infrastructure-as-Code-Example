terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "your-org-name"       # ← Replace with your actual TFC org

    workspaces {
      name = "infrastructure-as-code-aws"  # ← Match your actual workspace name
    }
  }
}
