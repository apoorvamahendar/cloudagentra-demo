terraform {
  backend "http" {
    address        = "http://localhost:8000/api/state/aws/a-74/iam"
    lock_address   = "http://localhost:8000/api/state/aws/a-74/iam/lock"
    unlock_address = "http://localhost:8000/api/state/aws/a-74/iam/unlock"
    lock_method    = "LOCK"
    unlock_method  = "UNLOCK"
  }

  encryption {
    key_provider "pbkdf2" "mykey" {
      passphrase = var.tofu_state_passphrase
    }

    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.mykey
    }

    method "unencrypted" "off" {}

    state {
      method = method.unencrypted.off

      fallback {
        method = method.aes_gcm.default
      }
    }

    plan {
      method = method.unencrypted.off

      fallback {
        method = method.aes_gcm.default
      }
    }
  }
}

variable "tofu_state_passphrase" {
  type      = string
  sensitive = true
}
