
#Область ПрограммныйИнтерфейс

Функция ЗапроситьОценкуGET(Запрос)
	
	Ключ = Запрос["ПараметрыЗапроса"].Получить("id");
	Если Ключ = Неопределено Тогда
		Ответ = Новый HTTPСервисОтвет(404);
		Возврат Ответ;
	КонецЕсли;
	
	ЗапросКлючи = Новый Запрос(
	"ВЫБРАТЬ
	|	ДанныеОбратнойСвязи.Обращение КАК Обращение,
	|	Обращения.Номер КАК Номер,
	|	Обращения.Дата КАК Дата,
	|	Обращения.Тема КАК Тема
	|ИЗ
	|	РегистрСведений.CRM_ДанныеОбратнойСвязи КАК ДанныеОбратнойСвязи
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.CRM_Интерес КАК Обращения
	|		ПО ДанныеОбратнойСвязи.Обращение = Обращения.Ссылка
	|			И (ДанныеОбратнойСвязи.Ключ = &Ключ)");
	
	ЗапросКлючи.Параметры.Вставить("Ключ", Ключ);
	
	Оценка = Запрос["ПараметрыЗапроса"].Получить("mark");
	Если Оценка = Неопределено Тогда
		Оценка = 0;
	Иначе
		Оценка = Число(Оценка);
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	РезультатЗапроса = ЗапросКлючи.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Ответ = Новый HTTPСервисОтвет(404);
		Возврат Ответ;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	МенеджерЗаписи = РегистрыСведений.CRM_ДанныеОбратнойСвязи.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Ключ	= Ключ;
	МенеджерЗаписи.ДатаОценки	= Дата(1,1,1);
	МенеджерЗаписи.Прочитать();
	МенеджерЗаписи.Ключ			= Ключ;
	МенеджерЗаписи.Обращение	= Выборка.Обращение;
	МенеджерЗаписи.Оценка		= Оценка;
	МенеджерЗаписи.ДатаОценки	= ТекущаяДатаСеанса();
	Менеджерзаписи.Комментарий	= "";
	МенеджерЗаписи.Записать();
	
	НомерОбращения = ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(Выборка.Номер);
	ДатаОбращения = Формат(Выборка.Дата, "ДЛФ=D");
	ТемаОбращения = СокрЛП(Выборка.Тема);
	ПредставлениеОбращения = "Обращение №" + НомерОбращения + " от " + ДатаОбращения + " " + ТемаОбращения;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	ТекстОтвета = "<html>
	|<head>
	|<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"" />
	|<meta http-equiv=""X-UA-Compatible"" content=""""IE=Edge"" />
	|<style type=""text/css"">
	|body {
	|	font-family: Arial, sans-serif;
	|}
	|#marksinput {
	|	height: 48px;
	|	position: relative;
	|}
	|#send {
	|	padding: 10px;
	|	margin: 10px 0;
	|}
	|#marksinput input {
	|	margin: 0;
	|	top: 0;
	|	width: 48px;
	|	height: 48px;
	|	position: absolute;
	|	z-index: 0;
	|	display: block;
	|}
	|#marksinput label {
	|	background-image:url(""data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAPAAAABgCAMAAAAU7Q/jAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAMBQTFRF6+ehz8/PVlZWXpoB0NDQ/v7++9UB+pEA7eNsztgAqKio/eUAktcANjIs/6IA/QAA5+fngYGB8/DFxcXFycnJwMDAveJ7RgEBipcB8Wtr9/ji8vLyuMQAfcUAkF8B9aOjWVsB6gAAwswAeQ0B+8Jy29vbEjQBzMzMztZA+cvL+vr3l9Ir+90x0twA7kNDh80A+q5FvAEBsq0B/Ofjv2wB/fXui8wWxc8e1+AA6x8f3YYB38UBl90A+p4hpthM////U8oXDAAAAEB0Uk5T////////////////////////////////////////////////////////////////////////////////////AMJ7sUQAABCfSURBVHja1JwJQ+JIFscrmCCNYgNJEIPKJUajiIoo2mh//2+171Wl7srBTPeuW/bsRPqfIr+8o663Q36bLQiCUbe7WCy6owyuf1c0kGQjkPugH/1dfXff53HpiSkfLcI4DvEnhH8WcFNp9xnXh/iv0O/+YX0g9dj27t96fqLLu4jKaRn2ovgrggx7j6kyzP8H3tGf0wf/tv/Y0qvAQZepwzRNPc9L04i91iJk9ji23v+D+vAP9K89P1FeT4ryKPV8jzaf3kRvcb3UIIsK9d0/ok//hp5I84ZU7udy0egtC+sbqDsU67Nvpg9MYKb3TLW4xctM9ynXp4bb/e/1OjDVR15BgzsiT/uGan36TfVE2jf1i27wvSgK08Dov0qf/U19uOfzCD0FDkalemyRGgf0/Xj/n3pC81slL72D5zpd7/NWU79v/39YT4HTEv9XIz93OkXvG61Kv2//9fTRHnrCHDr0vOo7Ij/gDhS6eVVm+AZLX/FE/w09AsNsJlUiXD6z7qdRFNFXGsRc7/tlxKAf6Xreq+tS0YeG3nnJ9MGeegS2DKyEgxoZfhpFGPfyheaAIPK1S6FP/cBhgLC4f6c+DrkoVT23WJ+6LvnzALCnG7jd6OVvxm93egvVKSKMAogwzcBxp8d54VbVxil1CalnN8UoEl+lhb1b32n48nkir0oPIl9eLlJDT35nof6Cep1GTO/wI7gMdRNAohuFWgQzPW1M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"");
	|	background-repeat: no-repeat;
	|	margin: 0;
	|	top: 0;
	|	width: 48px;
	|	height: 48px;
	|	position: absolute;
	|	z-index: 1;
	|	cursor: pointer;
	|	display: block;
	|}
	|#label1, #mark1 {
	|	background-position-x: 0;
	|	background-position-y: 0;
	|	left: 0px;
	|}
	|#label2, #mark2 {
	|	background-position-x: -48px;
	|	background-position-y: 0;
	|	left: 58px;
	|}
	|#label3, #mark3 {
	|	background-position-x: -96px;
	|	background-position-y: 0;
	|	left: 116px;
	|}
	|#label4, #mark4 {
	|	background-position-x: -144px;
	|	background-position-y: 0;
	|	left: 174px;
	|}
	|#label5, #mark5 {
	|	background-position-x: -192px;
	|	background-position-y: 0;
	|	left: 232px;
	|}
	|#mark1:checked + label, #mark1:hover + label {
	|	background-position-y: -48px;
	|}
	|#mark2:checked + label, #mark2:hover + label {
	|	background-position-y: -48px;
	|}
	|#mark3:checked + label, #mark3:hover + label {
	|	background-position-y: -48px;
	|}
	|#mark4:checked + label, #mark4:hover + label {
	|	background-position-y: -48px;
	|}
	|#mark5:checked + label, #mark5:hover + label {
	|	background-position-y: -48px;
	|}
	|</style>
	|</head>
	|<body>
	|<p>"+ПредставлениеОбращения+"</p>
	|<p>Оценка</p>
	|<form action=""put"" method=""post"">
	|<input type=""text"" value="""+Ключ+""" name=""id"" hidden/>
	|<div id=""marksinput"">
	|	<input id=""mark1"" type=""radio"" value=""1"" name=""mark"""+?(Оценка = 1, " checked", "")+"/>
	|	<label id=""label1""; title=""Плохо"" for=""mark1""></label>
	|	<input id=""mark2"" type=""radio"" value=""2"" name=""mark"""+?(Оценка = 2, " checked", "")+"/>
	|	<label id=""label2""; title=""Ниже среднего"" for=""mark2""></label>
	|	<input id=""mark3"" type=""radio"" value=""3"" name=""mark"""+?(Оценка = 3, " checked", "")+"/>
	|	<label id=""label3""; title=""Средне"" for=""mark3""></label>
	|	<input id=""mark4"" type=""radio"" value=""4"" name=""mark"""+?(Оценка = 4, " checked", "")+"/>
	|	<label id=""label4""; title=""Хорошо"" for=""mark4""></label>
	|	<input id=""mark5"" type=""radio"" value=""5"" name=""mark"""+?(Оценка = 5, " checked", "")+"/>
	|	<label id=""label5""; title=""Отлично"" for=""mark5""></label>
	|</div>
	|<div>
	|<p>Комментарий</p>
	|<textarea name=""comment"" cols=""80"" rows=""10""></textarea>
	|</div>
	|<input id=""send"" type=""submit"" value=""Отправить""/>
	|</form>
	|</body>
	|</html>";
	
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.Заголовки.Вставить("content-type", "text/html");
	Ответ.УстановитьТелоИзСтроки(ТекстОтвета);
	
	Возврат Ответ;
	
КонецФункции

Функция УточнитьОценкуPOST(Запрос)
	
	СтруктураДанныхЗапроса = Новый Структура;
	СтруктураДанныхЗапроса.Вставить("id", "");
	СтруктураДанныхЗапроса.Вставить("mark", "");
	СтруктураДанныхЗапроса.Вставить("comment", "");
	
	ТелоЗапросаСтрокой = СтрЗаменить(Запрос.ПолучитьТелоКакСтроку(), "+", "%20");
	ПараметрыИЗначения = СтрРазделить(ТелоЗапросаСтрокой, "&", Ложь);
	Для Каждого ПараметрИЗначениеСтрокой Из ПараметрыИЗначения Цикл
		ПараметрИЗначениеМассив = СтрРазделить(ПараметрИЗначениеСтрокой, "=");
		Если Не ПараметрИЗначениеМассив.Количество() = 2 Тогда
			Продолжить;
		КонецЕсли;
		КлючПараметра = ПараметрИЗначениеМассив[0];
		ЗначениеПараметра = РаскодироватьСтроку(ПараметрИЗначениеМассив[1], СпособКодированияСтроки.URLВКодировкеURL);
		СтруктураДанныхЗапроса.Вставить(КлючПараметра, ЗначениеПараметра);
	КонецЦикла;
	
	Ключ = СтруктураДанныхЗапроса.id;
	Если Ключ = "" Тогда
		Ответ = Новый HTTPСервисОтвет(404);
		Возврат Ответ;
	КонецЕсли;
	
	Оценка = СтруктураДанныхЗапроса.mark;
	Комментарий = СтруктураДанныхЗапроса.comment;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ДанныеОбратнойСвязи.Обращение КАК Обращение
	|ИЗ
	|	РегистрСведений.CRM_ДанныеОбратнойСвязи КАК ДанныеОбратнойСвязи
	|ГДЕ
	|	ДанныеОбратнойСвязи.Ключ = &Ключ");
	
	Запрос.Параметры.Вставить("Ключ", Ключ);
	
	УстановитьПривилегированныйРежим(Истина);
	
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		Ответ = Новый HTTPСервисОтвет(404);
		Возврат Ответ;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	МенеджерЗаписи = РегистрыСведений.CRM_ДанныеОбратнойСвязи.СоздатьМенеджерЗаписи();
	МенеджерЗаписи.Ключ			= Ключ;
	МенеджерЗаписи.Обращение	= Выборка.Обращение;
	МенеджерЗаписи.Оценка		= Число(Оценка);
	МенеджерЗаписи.ДатаОценки	= ТекущаяДатаСеанса();
	Менеджерзаписи.Комментарий	= Комментарий;
	МенеджерЗаписи.Записать();
	
	УстановитьПривилегированныйРежим(Ложь);
	
	ТекстОтвета = "<html>
	|<head>
	|<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8""/>
	|<meta http-equiv=""X-UA-Compatible"" content=""IE=Edge"" />
	|<style type=""text/css"">
	|body {
	|	font-family: Arial, sans-serif;
	|}
	|</style>
	|</head>
	|<body>
	|Спасибо за оценку!
	|</body>
	|</html>";
	
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.Заголовки.Вставить("content-type", "text/html");
	Ответ.УстановитьТелоИзСтроки(ТекстОтвета);
	
	Возврат Ответ;
	
КонецФункции

Функция pingGET(Запрос)
	
	Ответ = Новый HTTPСервисОтвет(200);
	Ответ.УстановитьТелоИзСтроки("OK");
	Возврат Ответ;
	
КонецФункции

#КонецОбласти

