# Transformacja danych w formacie EDIFACT do formatu XML – EDI2XML_App

## Czas ćwiczenia

00:30

## Opis ćwiczenia

W tym ćwiczeniu stworzysz aplikacje integracyjną „EDI2XML_App”, która będzie monitorowała, czy we wskazanym przez Ciebie folderze pojawił sie plik w formacie `.edi`. Plik zostanie pobrany oraz sparsowany i przekazany do węzła mapującego wartości z dokumentu EDIFACT do odpowiednich pól w formacie XML. Sformatowaną wiadomość zostanie przesłane do kolejki MQ. 

## Cele

Po ukończeniu tego ćwiczenia powinieneś potrafić:
- Użyć węzła *FileInput* do przetwarzania komunikatów odczytywanych z plików.
- Użyć widoku *DFDL Test* do testowania, modelowania, analizowania i parsowania danych EDIFACT zgodnie ze schematem DFDL.
- Importować i korzystać z udostępnionych bibliotek.
- Użyć węzła Mapping do mapowania wiadomości w formacie EDIFACT do formatu XML.
- Stowrzyć politykę pozwalającą połączyć się z MQ.
- Skonfigurować menagera kolejek, kolejkę oraz węzeł MQInput.

## Wstęp

Firma logistyczna otrzymuje komunikaty w formacie `.edi` do zdefiniowanej lokalizacji. Potrzebujemy stowrzć aplikacje, która przetworzy i zrozumie poszczególne transakcje zawarte w pliku na następnie zmapuje je na odpowiedni format XML. Aplikacja powinna wrzucać zmapowane wiadomości do kolejki MQ, aby następna aplikacja mogła pobrać wiadomość nie zależnie od systemu wyłającego komunikat.

## Wymagania

- Środowisko warsztatowe z zainstalowanym [IBM App Connect Enterprise Toolkit (ACET)](https://www.ibm.com/docs/en/app-connect/12.0?topic=enterprise-download-ace-developer-edition-get-started).
- Środowisko warsztatowe z zainstalowanym [IBM MQ Server](hhttps://www.ibm.com/docs/en/ibm-mq/9.3?topic=windows-installing-server-using-launchpad) oraz [IBM MQ Explorer](https://www.ibm.com/docs/en/ibm-mq/9.3?topic=windows-installing-stand-alone-mq-explorer).
- Pobrany i rozpakowany folder z plikami potrzebnymi do ćwiczeń laboratoryjnych [labfiles](https://github.com/jawor96/Warsztaty_CP4I/tree/main/labfiles).
- Dostęp do narzędzia do testowania komunikacji (Postman lub SoapUI).

## Przygotowanie środowiska

Uruchom aplikacje IBM App Connect.

1.	Kliknij w Search w pasku narzędzi i wyszukaj aplikacji IBM App Connect Enterprise Toolkit 13/12.
2.	Kliknij w aplikacje, aby ją uruchomić.

![](../images/001.png)

3.	Zostaw domyślny **Workspace**: `<path-to-ACE>\IBM\ACET13(12)\workspace` i kliknij **Launch**. Aplikacja ACET uruchomi się po chwili.

![](../images/002.png)

4. Kliknij **File** i **Import..**, aby zaimportować biblioteki zawierające schematy komunikatów *EDIFACT*.

![](../images/101.PNG)

5. W oknie "Import", wybierz **Project Interchange** i kliknij *Next*.

![](../images/102.PNG)

6. Kliknij **Browse...** w "*From zip file*" i wybierz **EDIFACT-Transport-D96A-Example.zip** z folderu `labfiles`, a następnie kliknij **Open**.

![](../images/103.PNG)

7. Wybierz dwie dostępne biblioteki i kliknij **Finish**.

![](../images/104.PNG)

Zaimporotwałeś potrzebne biblioteki ze schematem transakcji EDIFACT analizowanej podczas tego scenariusza. W następnej cześci przetestujesz modelowanie danych EDIFACT z użyciem DFDL.

## Modelowanie danych EDIFACT z użyciem DFDL

Ta cześć ćwiczenia pokazuje, jak modelować dane UN/EDIFACT za pomocą schematu DFDL.

UN/EDIFACT to międzynarodowy standard wymiany informacji EDI w sektorach komercyjnych i niekomercyjnych. Strumienie danych UN/EDIFACT mają strukturę hierarchiczną, w której najwyższy poziom jest określany jako "interchange", a niższe poziomy zawierają wiele komunikatów, które składają się z segmentów, które z kolei składają się z kompozytów. Kompozyty z kolei składają się z elementów. Segmenty, kompozyty i elementy są oddzielone separatorami.

Edytor schematów DFDL, z którego skorzystamy, służy do przeglądania modelu i analizowania przykładowych plików danych EDIFACT.

Biblioteka **EDIFACT-Transport-SWGTECH-D96A** zawiera parę schematów DFDL, które modelują komunikaty UN/EDIFACT dla wersji D.96A. Dostępna jest definicje typów komunikatów `IFTMIN`. Biblioteka zawiera pliki danych testowych. Biblioteka EDIFACT-Common zawiera schemat DFDL do definiowania wartości domyślnych dla właściwości DFDL oraz schemat DFDL do modelowania segmentów usług Uxx i komunikatów usług.

1. Biblioteki są wyświetlane w widoku **Application Development** obszaru roboczego. Kliknij dwukrotnie Schemat DFDL `EDIFACT-Transport-SWGTECH-Messages-D96A.xsd` w bibliotece **EDIFACT-Transport-SWGTECH-D96A**. Komunikat *Interchange* jest podświetlony i modeluje całą wymianę EDIFACT. Główny widok edytora pokazuje logiczne komponenty komunikatu, takie jak elementy i sekwencje. Strukturę komunikatu *Interchange* można eksplorować poprzez rozwijanie elementów.

![](../images/105.PNG)

Renderowanie każdego komponentu logicznego jest opisane przez właściwości DFDL w zakładce "**Representation Properties**". Właściwości DFDL mogą być określone lokalnie na komponencie lub mogą być dziedziczone z predefiniowanych zestawów właściwości DFDL. Odziedziczone właściwości mają ikonę "drzewka" pokazaną obok nich. Najechanie kursorem na ikonę ujawnia, gdzie zdefiniowana jest właściwość. W tym schemacie odziedziczone właściwości są uzyskiwane ze schematu **IBM_EDI_Format.xsd** w bibliotece *EDIFACT-Common*.

2. Ponieważ ustawienia ograniczników w wymianie EDIFACT mogą się różnić, właściwości *DFDL Terminator*, *Separator*, *Escape Character* i *Decimal Separator* są ustawiane dynamicznie przy użyciu wyrażeń DFDL, które odnoszą się do zmiennych DFDL. Zmienne mają wartości domyślne i są zastępowane przez ustawienia w segmencie *UNA*, jeśli są obecne. Można to zobaczyć, rozwijając element *UNA* w *Interchange*, wybierając dowolny element podrzędny i klikając kartę **Variables** obok opcji **Representation Properties**.

![](../images/106.PNG)

3. Będziesz testować parsowanie przykładowych danych EDIFACT za pomocą komunikatu *Interchange*. Parsowanie testowe odbywa się w edytorze DFDL. Przed parsowaniem testowym należy przełączyć się na perspektywę DFDL Test, klikając **Window > Perspective > Open Perspective . Other**, a następnie klikając **DFDL Test** i **Open**.

![](../images/107.PNG)

![](../images/108.PNG)

4. Przetestuj parsowanie przykładowego pliku danych:

- Kliknij **Test Parse Model** na pasku narzędzi edytora DFDL. Otworzy się okno **Test Parse Model**.

![](../images/109.PNG)

- W sekcji Message wybierz opcję **Interchange**.
- W sekcji **Parser Input** wybierz opcję *Content from a data file*, a następnie kliknij przycisk **Browse**.
- Wybierz `plik edifact.edi` z **EDIFACT-Transport-SWGTECH-D96A**, a następnie kliknij **OK**.

![](../images/110.PNG)

- Ustaw kodowanie na **ASCII**. Kliknij **OK**.

![](../images/111.PNG)

5. Wyświetlone zostaną wyniki parsowania testowego. Powinien zostać wyświetlony komunikat *"Parsowanie zakończone pomyślnie"*. Możesz zamknąć ten komunikat.
6. Przeanalizowany plik danych można wyświetlić w widoku **DFDL Test - Parse**. Wyniki parsowania można wyświetlić w widoku **DFDL Test - Logical Instance** jako drzewo lub XML. Dziennik działań parsera można wyświetlić w widoku **DFDL Test - Trace**.

![](../images/112.PNG)

![](../images/113.PNG)

7. Przetestuj serializację instancji logicznej, która powstała w wyniku parsowania:

- Kliknij **Test Serialize Model** na pasku narzędzi edytora DFDL. Otworzy się okno **Test Serialize Model**.

![](../images/114.PNG)

- W sekcji **Serializer Input** wybierz **Content from a DFDL Test - Logical Instance**.
- Ustaw kodowanie na **ASCII**. Kliknij **OK**.

![](../images/115.PNG)

8. Wyświetlone zostaną wyniki testu serializacji. Powinien zostać wyświetlony komunikat *"Serializacja zakończone pomyślnie"*. Możesz zamknąć ten komunikat.
9. Zserializowany plik danych można wyświetlić w widoku **DFDL Test - Serialize**. Dziennik działań serializatora można wyświetlić w widoku **DFDL Test - Trace**.

![](../images/116.PNG)

Dostarczone schematy DFDL pozwalaną na analizę komunikatów w potrzebnym formacie EDIFACT.

Jeśli wymagana jest obsługa składni UN/EDIFACT w wersji 3 zamiast składni w wersji 4, można edytować plik `IBM_EDI_Format.xsd` w bibliotece EDIFACT-Common. W tym pliku należy ustawić zmienną RepeatSep DFDL tak, aby przyjmowała wartość domyślną „**+**” (plus) zamiast „*” (gwiazdka).

Jeśli chcesz obsługiwać „**,**” (przecinek) jako domyślny separator dziesiętny zamiast „**.**” (kropka), możesz edytować plik `IBM_EDI_Format.xsd` w bibliotece EDIFACT-Common. W tym pliku należy zmienić zmienną DecimalSep DFDL, aby przyjąć domyślną wartość „**,**” (przecinek) zamiast „**.**” (kropka).

Obie biblioteki współdzielone można wdrożyć do węzła integracyjnego w celu wykorzystania przez przepływy komunikatów.

## Tworzenie aplikacji integracyjnej EDI2XML_App

