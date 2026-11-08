packer {
  required_plugins {
    virtualbox = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "iso_name" {
  type    = string
  default = "debian-13.7.0-arm64-netinst.iso"
}

variable "iso_checksum" {
  type = string
}

source "virtualbox-iso" "debian" {
  iso_urls = [
    "iso/${var.iso_name}",
    "https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/${var.iso_name}",
  ]
  iso_checksum = "sha256:${var.iso_checksum}"

  vm_name       = "packer-debian-13-arm64"
  guest_os_type = "Debian_arm64"
  firmware      = "efi"
  cpus          = 2
  memory        = 2048
  disk_size     = 20000

  hard_drive_interface = "virtio"
  iso_interface        = "virtio"
  guest_additions_mode = "disable"

  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--nic-type1", "virtio"],
    ["modifyvm", "{{ .Name }}", "--usb-xhci", "on"],
    ["modifyvm", "{{ .Name }}", "--keyboard", "usb", "--mouse", "usb"],
    ["modifyvm", "{{ .Name }}", "--graphicscontroller", "qemuramfb"],
  ]

  http_directory = "http"

  boot_wait = "5s"
  boot_command = [
    "c<wait>",
    "linux /install.a64/vmlinuz auto=true priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg --- quiet<enter><wait>",
    "initrd /install.a64/initrd.gz<enter><wait>",
    "boot<enter>",
  ]

  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_timeout      = "60m"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"

  headless = false
}

build {
  sources = ["source.virtualbox-iso.debian"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | sudo -S sh -eux '{{ .Path }}'"
    script          = "scripts/vagrant.sh"
  }

  post-processor "vagrant" {
    output            = "output/debian-13-arm64.box"
    compression_level = 6
  }
}