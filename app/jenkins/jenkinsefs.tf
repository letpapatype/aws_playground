resource "kubernetes_storage_class" "aws_efs_sc" {
  metadata {
    name = "aws-efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = data.aws_efs_file_system.by_id.id
    directoryPerms   = "700"
    gidRangeStart    = "1000"
    gidRangeEnd      = "2000"
    basePath         = "/jenkins"
  }
}

resource "kubernetes_persistent_volume" "aws_pv" {
  metadata {
    name = "aws-pv"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = kubernetes_storage_class.aws_efs_sc.metadata[0].name
    volume_mode                      = "Filesystem"
    persistent_volume_source {
      csi {
        driver       = "efs.csi.aws.com"
        volume_handle = data.aws_efs_file_system.by_id.id
        fs_type      = "efs"
        read_only    = false
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_aws_pvc" {
  metadata {
    name      = "jenkins-aws-pvc"
    namespace = "jenkins"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "aws-efs-sc"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}