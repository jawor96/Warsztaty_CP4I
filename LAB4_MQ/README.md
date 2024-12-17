# Konfiguracja MQ w środowisku kontenerowym

## Czas ćwiczenia

01:00

## Opis ćwiczenia

W tym ćwiczeniu stworzysz i skonfigurujesz menedżera kolejek (Queue Manager) w kontenerze. Następnie umieścisz w kolejce wiadomość wykorzystując konsolę IBM MQ Console. W kolejnym kroku stowrzysz politykę MQPolicy i skonfigurujesz połączenie MQ z ACE. Na koniec ćwiczenia stworzysz prostą aplikacje integracyjną wyciągającą wrzuconą wiadomość z kolejki MQ.

## Cele

Po ukończeniu tego ćwiczenia powinieneś potrafić:
- Stworzysz i skonfigurować QM w kontenerze.
- Poruszać się w IMB MQ Console.
- Skonfigurować połączenie między MQ i ACE.
- Pobrać wiadomość z kolejki MQ.

## Wymagania

- Środowisko warsztatowe z zainstalowanym [IBM App Connect Enterprise Toolkit (ACET)](https://www.ibm.com/docs/en/app-connect/12.0?topic=enterprise-download-ace-developer-edition-get-started).
- [Podman](https://podman.io/getting-started/installation) lub [Docker](https://docs.docker.com/get-docker/).
- Dostęp do narzędzia do testowania komunikacji (Postman lub SoapUI).

## Konfiguracja menedżera kolejek w kontenerze

### Pobierz obraz kontenera MQ

Kontenery są uruchamiane z obrazów, a obrazy są tworzone na podstawie specyfikacji podanej w pliku Dockerfile. Użyjemy wstępnie zbudowanego obrazu serwera IBM MQ, abyśmy mogli uruchomić nasz kontener bez konieczności budowania obrazu. Ostatecznie otrzymamy działającą instalację MQ i menedżera kolejek, który jest wstępnie skonfigurowany z obiektami gotowymi do pracy dla programistów.

1. Pobierz obraz z IBM Container Registry, który zawiera najnowszą wersję serwera MQ.

```
podman pull icr.io/ibm-messaging/mq:latest
```

2. Po zakończeniu sprawdź, jakie obrazy są dostępne.

```
podman images
```

### Uruchomienie kontenera MQ z obrazu.

Teraz, gdy obraz serwera MQ znajduje się w lokalnym repozytorium obrazów, można uruchomić kontener.

Podczas konfigurowania kontenera używany jest system plików w pamięci, który jest usuwany po usunięciu kontenera. Dane menedżera kolejek i kolejek są zapisywane w tym systemie plików. Aby uniknąć utraty danych menedżera kolejek i kolejek, możemy użyć Volumes.

Volumes są dołączane do kontenerów podczas ich uruchamiania i utrzymują się po usunięciu kontenera. Po uruchomieniu nowego kontenera można dołączyć istniejący wolumin, a następnie ponownie użyć menedżera kolejek i danych kolejki.

1. Aby stowrzyć Volume wykonaj polecenie:

```
podman volume create qm1data
```

2. Uruchom kontener serwera MQ.

Edytując polecenie możesz ustawić własne hasło do łączenia się z aplikacjami. Hasło to będzie potrzebne później, zarówno dla demonstracyjnej aplikacji klienckiej, jak i podczas uruchamiania własnych aplikacji klienckich. W tym przykładzie ustawiamy hasło na „passw0rd”, ale można też wybrać własne.

```
 podman run --env LICENSE=accept --env MQ_QMGR_NAME=QM1 --volume qm1data:/mnt/mqm --publish 1414:1414 --publish 9443:9443 --detach --env MQ_APP_USER=app --env MQ_APP_PASSWORD=passw0rd --env MQ_ADMIN_USER=admin --env MQ_ADMIN_PASSWORD=passw0rd --name QM1 icr.io/ibm-messaging/mq:latest
```

Twój menedżer kolejek został skonfigurowany z prostą domyślną konfiguracją, aby umożliwić podłączenie pierwszej aplikacji klienckiej.

Dodaliśmy kilka parametry do polecenia run np. akceptacja licencji na IBM MQ Advanced dla deweloperów i nazwać menedżera kolejek „QM1”, w którym będzie znajdować się nasza kolejka.

Ponieważ MQ działa wewnątrz kontenera, będzie odizolowany od reszty świata, więc otworzyliśmy kilka portów używanych przez MQ.

Listener menedżera kolejek nasłuchuje na porcie 1414 dla połączeń przychodzących, a port 9443 jest używany przez konsolę MQ.

3. Daj kontenerowi chwilę na uruchomienie, a następnie sprawdź, czy działa.

```
podman ps
```

Gratulacje! Właśnie stworzyłeś swój pierwszy prosty menedżer kolejek. Nazywa się QM1 i działa wewnątrz kontenera.

### Podsumowanie

Pobrałeś wstępnie zbudowany obraz MQ i uruchomiłeś go w kontenerze. Obiekty IBM MQ i uprawnienia, których aplikacje klienckie potrzebują do łączenia się z menedżerem kolejek oraz do wysyłania i odbierania wiadomości z i do kolejki zostały stworzone automatycznie. Podman i MQ korzystają z zasobów hosta i łączności lokalnej maszyny.

Wewnątrz kontenera instalacja MQ ma następujące obiekty:

- Menedżer kolejek QM1
- Kolejka DEV.QUEUE.1
- Kanał: DEV.APP.SVRCONN
- Listener: SYSTEM.LISTENER.TCP.1 na porcie 1414

Kolejka, która będzie używana, DEV.QUEUE.1, działa w menedżerze kolejek QM1. Menedżer kolejek ma również listener, który nasłuchuje połączeń przychodzących na porcie 1414. Aplikacje klienckie mogą łączyć się z menedżerem kolejek i mogą otwierać, umieszczać i pobierać wiadomości oraz zamykać kolejkę.

Aplikacje używają kanału MQ do łączenia się z menedżerem kolejek. Dostęp do tych trzech obiektów jest ograniczony na różne sposoby. Na przykład użytkownik „app”, który jest członkiem grupy „mqclient”, może używać kanału DEV.APP.SVRCONN do łączenia się z menedżerem kolejek QM1 i jest upoważniony do umieszczania i pobierania wiadomości do i z kolejki DEV.QUEUE.1.

Wszystkie obiekty MQ i uprawnienia, których potrzebuje aplikacja kliencka, są tworzone i konfigurowane podczas uruchamiania kontenera serwera MQ.

## 

## Podsumowanie

Menedżera kolejek (serwer) IBM MQ można pobrać, zainstalować i uruchomić równie na inne sposoby sposoby:

- W kontenerze (to laboratorium) lub [Red Hat OpenShift Container Platform](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-openshift/).
- W chmurze [IBM Cloud](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-cloud/), [AWS](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-cloud-aws/) (lub [AWS przy użyciu Ansible](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-cloud-aws-ansible/) lub [AWS przy użyciu Terraform](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-cloud-aws-terraform/)), [Microsoft Azure](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-cloud-azure/) lub [Google Cloud](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-cloud-google/).
- Na różnych systemach operacyjnych: [Linux/Ubuntu](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-ubuntu/) lub [Windows](https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-windows/). W przypadku macOS użyj MQ w kontenerach (to laboratorium).
