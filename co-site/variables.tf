variable "env_tag"{
    type = string

}

variable "system1_tag"{
    default = "cpe"
}

variable "system2_tag"{
    default = "cksite"
}

variable "env"{
    type     = string
    nullable = true
    default  = null
}