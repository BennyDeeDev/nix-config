{
  nixos = {
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      domain = "docs.benjaminderksen.com";
      settings = {
        PAPERLESS_DBENGINE = "sqlite";
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_TASK_WORKERS = 1;
        PAPERLESS_THREADS_PER_WORKER = 2;
      };
      tesseractLanguages = null;
    };

    my.restic.paperless = {
      repository = "/mnt/nas/restic/paperless-restic";
      paths = [ "/var/lib/paperless" ];
      services = [
        "paperless-consumer.service"
        "paperless-scheduler.service"
        "paperless-task-queue.service"
        "paperless-web.service"
      ];
      mountPoint = "/mnt/nas/restic";
    };
  };
}
