import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_languages.dart';

class Translations {
  final AppLanguage language;

  Translations(this.language);

  static Translations of(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    return Translations(lang);
  }

  // --- Sidebar ---
  String get sidebarDashboard => language == AppLanguage.en ? "Dashboard" : "Табло";
  String get sidebarPatients => language == AppLanguage.en ? "Patients" : "Пациенти";
  String get sidebarAppointments => language == AppLanguage.en ? "Appointments" : "Прегледи";
  String get sidebarStorage => language == AppLanguage.en ? "Storage" : "Склад";
  String get sidebarReports => language == AppLanguage.en ? "Reports" : "Отчети";
  String get sidebarSettings => language == AppLanguage.en ? "Settings" : "Настройки";
  String get commonSearchHint => language == AppLanguage.en ? "Search anything..." : "Търсене...";
  String get appTitle => language == AppLanguage.en ? "Medical Clinic Management" : "Управление на медицинска клиника";
  String get brandName => language == AppLanguage.en ? "HealthZone" : "HealthZone";
  String get commonUnknown => language == AppLanguage.en ? "Unknown" : "Неизвестно";

  // --- Common ---
  String get commonAdd => language == AppLanguage.en ? "Add" : "Добави";
  String get commonSave => language == AppLanguage.en ? "Save" : "Запази";
  String get commonCancel => language == AppLanguage.en ? "Cancel" : "Отказ";
  String get commonDelete => language == AppLanguage.en ? "Delete" : "Изтрий";
  String get commonConfirm => language == AppLanguage.en ? "Confirm" : "Потвърди";
  String get commonBack => language == AppLanguage.en ? "Back" : "Назад";
  String get commonNA => language == AppLanguage.en ? "N/A" : "Н/А";
  String get commonDoctorPrefix => language == AppLanguage.en ? "Dr." : "Д-р";

  // --- Dashboard ---
  String get dashboardTotalPatients => language == AppLanguage.en ? "Total Patients" : "Общо пациенти";
  String get dashboardTodayAppointments => language == AppLanguage.en ? "Today's Appointments" : "Прегледи за днес";
  String get dashboardStorageAlerts => language == AppLanguage.en ? "Storage Alerts" : "Предупреждения от склада";
  String get dashboardRevenue => language == AppLanguage.en ? "Monthly Revenue" : "Месечен приход";
  String get dashboardRecentActivity => language == AppLanguage.en ? "Recent Activity" : "Скорошна активност";
  String get dashboardOverview => language == AppLanguage.en ? "Dashboard Overview" : "Общ преглед";
  String get dashboardSubtitle => language == AppLanguage.en ? "Here's what's happening today." : "Ето какво се случва днес.";
  String get dashboardRecentPatients => language == AppLanguage.en ? "Recent Patients" : "Последни пациенти";
  String get dashboardNoUpcomingAppts => language == AppLanguage.en ? "No upcoming appointments for today." : "Няма предстоящи прегледи за днес.";
  
  String get tableId => language == AppLanguage.en ? "ID" : "ID";
  String get tableName => language == AppLanguage.en ? "NAME" : "ИМЕ";
  String get tablePhone => language == AppLanguage.en ? "PHONE" : "ТЕЛЕФОН";
  String get tableLastVisit => language == AppLanguage.en ? "LAST VISIT" : "ПОСЛЕДНО ПОСЕЩЕНИЕ";
  String get tableNoVisits => language == AppLanguage.en ? "No visits" : "Няма посещения";

  // --- Patients ---
  String get patientsTitle => language == AppLanguage.en ? "Patients Management" : "Управление на пациенти";
  String get patientsAddButton => language == AppLanguage.en ? "Add Patient" : "Добави пациент";
  String get patientsSearchHint => language == AppLanguage.en ? "Search by name, ID, EGN, or phone" : "Търсене по име, ID, ЕГН или телефон";
  String get patientsNotFound => language == AppLanguage.en ? "No patients found" : "Няма намерени пациенти";
  String get patientsTableInfo => language == AppLanguage.en ? "PATIENT INFO" : "ИНФОРМАЦИЯ ЗА ПАЦИЕНТА";
  String get patientsTableActions => language == AppLanguage.en ? "ACTIONS" : "ДЕЙСТВИЯ";

  // Dialogs
  String get patientsDialogAddTitle => language == AppLanguage.en ? "Add New Patient" : "Добавяне на нов пациент";
  String get patientsDialogEditTitle => language == AppLanguage.en ? "Edit Patient" : "Редактиране на пациент";
  String get patientsDialogRemoveTitle => language == AppLanguage.en ? "Remove Patient" : "Премахване на пациент";
  String get patientsDialogRemoveConfirm => language == AppLanguage.en ? "Are you sure you want to remove this patient from the system?" : "Сигурни ли сте, че искате да премахнете този пациент от системата?";
  
  String get patientsFieldFirstName => language == AppLanguage.en ? "First Name" : "Име";
  String get patientsFieldSurname => language == AppLanguage.en ? "Surname" : "Фамилия";
  String get patientsFieldEGN => language == AppLanguage.en ? "EGN" : "ЕГН";
  String get patientsFieldPhone => language == AppLanguage.en ? "Phone" : "Телефон";
  String get patientsFieldEmail => language == AppLanguage.en ? "Email" : "Имейл";
  String get patientsFieldConditions => language == AppLanguage.en ? "Medical Conditions / Ills" : "Медицински състояния / Заболявания";
  String get patientsFieldRequired => language == AppLanguage.en ? "Required" : "Задължително";

  String get patientsViewFullHistory => language == AppLanguage.en ? "View Full History" : "Виж пълна история";
  String get patientsClose => language == AppLanguage.en ? "Close" : "Затвори";
  String get patientsSaveChanges => language == AppLanguage.en ? "Save Changes" : "Запази промените";
  String get patientsSavePatient => language == AppLanguage.en ? "Save Patient" : "Запази пациента";
  String get patientsNotFoundDetail => language == AppLanguage.en ? "Patient not found." : "Пациентът не е намерен.";
  String get patientsPortfolio => language == AppLanguage.en ? "Patient Portfolio" : "Портфолио на пациента";
  String get patientsHistoryNoAppts => language == AppLanguage.en ? "No appointments found for this patient." : "Няма намерени прегледи за този пациент.";
  String get patientsHistoryUpcoming => language == AppLanguage.en ? "Upcoming Appointments" : "Предстоящи прегледи";
  String get patientsHistoryPast => language == AppLanguage.en ? "Visit History" : "История на посещенията";
  String get patientsHistoryNoPast => language == AppLanguage.en ? "No past visit history found." : "Няма намерена история на минали посещения.";
  String get patientsTreatmentNotes => language == AppLanguage.en ? "Treatment & Notes" : "Лечение и бележки";

  // --- Appointments ---
  String get appointmentsTitle => language == AppLanguage.en ? "Calendar & Scheduling" : "Календар и график";
  String get appointmentsAddButton => language == AppLanguage.en ? "Add Appointment" : "Добави преглед";
  String get appointmentsNoApptsDay => language == AppLanguage.en ? "No appointments scheduled for this day." : "Няма насрочени прегледи за този ден.";
  String get appointmentsTodaySchedule => language == AppLanguage.en ? "Today's Schedule" : "График за днес";

  // Dialogs
  String get appointmentsDialogCancelTitle => language == AppLanguage.en ? "Cancel Appointment" : "Отказване на преглед";
  String get appointmentsDialogCancelConfirm => language == AppLanguage.en ? "Are you sure you want to cancel this appointment?" : "Сигурни ли сте, че искате да откажете този преглед?";
  String get appointmentsDialogCancelNo => language == AppLanguage.en ? "No, Keep It" : "Не, запази го";
  String get appointmentsDialogCancelYes => language == AppLanguage.en ? "Yes, Cancel" : "Да, откажи";

  String get appointmentsDialogAddTitle => language == AppLanguage.en ? "Schedule New Appointment" : "Насрочване на нов преглед";
  String get appointmentsDialogEditTitle => language == AppLanguage.en ? "Edit Appointment" : "Редактиране на преглед";
  
  String get appointmentsFieldSearchPatient => language == AppLanguage.en ? "Search & Select Patient" : "Търсене и избор на пациент";
  String get appointmentsFieldSearchHint => language == AppLanguage.en ? "Type Name, ID, EGN or Phone..." : "Въведете име, ID, ЕГН или телефон...";
  String get appointmentsFieldDate => language == AppLanguage.en ? "Date" : "Дата";
  String get appointmentsFieldTime => language == AppLanguage.en ? "Time" : "Час";
  String get appointmentsFieldPlace => language == AppLanguage.en ? "Place" : "Място";
  String get appointmentsFieldProcedure => language == AppLanguage.en ? "Procedure" : "Процедура";
  String get appointmentsFieldType => language == AppLanguage.en ? "Type" : "Тип";
  String get appointmentsFieldNotes => language == AppLanguage.en ? "Notes" : "Бележки";
  String get appointmentsFieldSchedule => language == AppLanguage.en ? "Schedule" : "Насрочване";

  String get appointmentsPlaceClinic => language == AppLanguage.en ? "Clinic" : "Клиника";
  String get appointmentsPlaceHome => language == AppLanguage.en ? "Home Visit" : "Домашно посещение";

  String get appointmentsErrorNoPatients => language == AppLanguage.en ? "Please add patients first." : "Моля, първо добавете пациенти.";
  String get appointmentsErrorNoProcedures => language == AppLanguage.en ? "Please add at least one procedure in Settings." : "Моля, добавете поне една процедура в Настройки.";

  // --- Appointment Details Modal ---
  String get aptDetailsTitle => language == AppLanguage.en ? "Appointment Details" : "Детайли за прегледа";
  String get aptDetailsFieldPatient => language == AppLanguage.en ? "Patient" : "Пациент";
  String get aptDetailsSuppliesTitle => language == AppLanguage.en ? "Used Supplies & Medications" : "Използвани консумативи и медикаменти";
  String get aptDetailsNoItems => language == AppLanguage.en ? "No items logged yet." : "Няма регистрирани елементи.";
  String get aptDetailsSearchHint => language == AppLanguage.en ? "Search Supply/Medication (e.g. Syringe)" : "Търсене на консуматив/лекарство (напр. Спринцовка)";
  String get aptDetailsHistoryButton => language == AppLanguage.en ? "Patient History" : "История на пациента";
  String get aptDetailsSaveItems => language == AppLanguage.en ? "Save Used Items" : "Запази използваните елементи";

  // --- Storage ---
  String get storageTitle => language == AppLanguage.en ? "Storage & Inventory" : "Склад и инвентар";
  String get storageAddButton => language == AppLanguage.en ? "Add Storage Item" : "Добави артикул";
  String get storageSearchHint => language == AppLanguage.en ? "Search inventory by name or category..." : "Търсене на инвентар по име или категория...";
  String get storageNoRecords => language == AppLanguage.en ? "No inventory records found." : "Няма намерени записи в инвентара.";
  String get storageTableItemName => language == AppLanguage.en ? "ITEM NAME" : "ИМЕ НА АРТИКУЛА";
  String get storageTableCategory => language == AppLanguage.en ? "CATEGORY" : "КАТЕГОРИЯ";
  String get storageTableQuantity => language == AppLanguage.en ? "QUANTITY" : "КОЛИЧЕСТВО";
  String get storageTableExpiration => language == AppLanguage.en ? "EXPIRATION" : "СРОК НА ГОДНОСТ";

  String get storageCategoryMedication => language == AppLanguage.en ? "Medication" : "Медикаменти";
  String get storageCategoryEquipment => language == AppLanguage.en ? "Equipment" : "Оборудване";
  String get storageCategorySupplies => language == AppLanguage.en ? "Supplies" : "Консумативи";

  String get storageFieldQty => language == AppLanguage.en ? "Quantity" : "Количество";
  String get storageFieldExpiration => language == AppLanguage.en ? "Expiration (Optional)" : "Срок на годност (по избор)";
  String get storageNoExpiry => language == AppLanguage.en ? "No Expiry" : "Без срок";
  String get storageSelectSpecific => language == AppLanguage.en ? "Select Specific Item" : "Избор на конкретен артикул";

  String get storageErrorInvalidQty => language == AppLanguage.en ? "Invalid quantity" : "Невалидно количество";
  String get storageErrorSelectItem => language == AppLanguage.en ? "Please select an item" : "Моля, изберете артикул";

  String get storageDialogRemoveTitle => language == AppLanguage.en ? "Remove Storage Item" : "Премахване на артикул";
  String get storageDialogRemoveConfirm => language == AppLanguage.en ? "Are you sure you want to remove this item from the inventory?" : "Сигурни ли сте, че искате да премахнете този артикул от инвентара?";

  // --- Reports ---
  String get reportsTitle => language == AppLanguage.en ? "Dashboard & Analytics" : "Табло и анализи";
  String get reportsSubtitle => language == AppLanguage.en ? "Real-time insights and generated reports." : "Данни в реално време и генерирани отчети.";
  String get reportsKpiTotalPatients => language == AppLanguage.en ? "Total Patients" : "Общо пациенти";
  String get reportsKpiApptsMonth => language == AppLanguage.en ? "Appointments This Month" : "Прегледи за месеца";
  String get reportsKpiLowStock => language == AppLanguage.en ? "Low Stock Alerts" : "Сигнали за ниска наличност";
  String get reportsChartWeeklyTraffic => language == AppLanguage.en ? "Weekly Appointment Traffic" : "Седмичен трафик на прегледи";
  String get reportsChartProcedures => language == AppLanguage.en ? "Procedures Breakdown" : "Разбивка по процедури";
  String get reportsNoProcedureData => language == AppLanguage.en ? "No procedure data yet." : "Все още няма данни за процедури.";
  String get reportsGenerationTitle => language == AppLanguage.en ? "Report Generation" : "Генериране на отчети";
  String get reportsDailyTitle => language == AppLanguage.en ? "Daily Reports" : "Дневни отчети";
  String get reportsDailyDesc => language == AppLanguage.en ? "End of day summaries, patient intake totals, and revenue metrics." : "Обобщения за края на деня, общ брой приети пациенти и приходи.";
  String get reportsDailyButton => language == AppLanguage.en ? "View Daily" : "Виж дневни";
  String get reportsMonthlyTitle => language == AppLanguage.en ? "Monthly Reports" : "Месечни отчети";
  String get reportsMonthlyDesc => language == AppLanguage.en ? "End of month summaries, overall patient intake totals, and comprehensive metrics." : "Обобщения за края на месеца, общ брой пациенти и подробни показатели.";
  String get reportsMonthlyButton => language == AppLanguage.en ? "View Monthly" : "Виж месечни";

  // --- Report Preview Dialog ---
  String get reportsPreviewDailyTitle => language == AppLanguage.en ? "Daily Report" : "Дневен отчет";
  String get reportsPreviewMonthlyTitle => language == AppLanguage.en ? "Monthly Reports" : "Месечни отчети";
  String get reportsPreviewSectionAppts => language == AppLanguage.en ? "Patients Seen & Appointments" : "Видяни пациенти и прегледи";
  String get reportsPreviewSectionInventory => language == AppLanguage.en ? "Inventory Consumption" : "Консумация на инвентар";
  String get reportsPreviewNoInventory => language == AppLanguage.en ? "No inventory recorded in these visits." : "Няма записан инвентар при тези посещения.";
  String get reportsPreviewSectionCritical => language == AppLanguage.en ? "Critical Storage Warnings (< 14 Days Expiry)" : "Критични предупреждения за склад (< 14 дни срок)";
  String get reportsPreviewNoExpiringSoon => language == AppLanguage.en ? "No items expiring soon." : "Няма артикули с изтичащ срок скоро.";
  String get reportsPreviewExportPDF => language == AppLanguage.en ? "Export PDF" : "Експорт в PDF";
  String get reportsPreviewTableTimeDate => language == AppLanguage.en ? "Time/Date" : "Час/Дата";
  String get reportsPreviewTableQtyUsed => language == AppLanguage.en ? "Quantity Used" : "Използвано количество";
  String get reportsPreviewTableRemaining => language == AppLanguage.en ? "Remaining Stock" : "Оставащ запас";
  String get reportsPreviewTableUsedShort => language == AppLanguage.en ? "Used" : "Използвани";
  String get reportsPreviewTableRemainingShort => language == AppLanguage.en ? "Remaining" : "Оставащи";

  // --- Settings ---
  String get settingsTitle => language == AppLanguage.en ? "Settings & Control Panel" : "Настройки и контролен панел";
  String get settingsSubtitle => language == AppLanguage.en ? "Manage themes, forms, data resets, and system variables." : "Управление на теми, форми, нулиране на данни и системни променливи.";
  
  String get settingsCatAppearance => language == AppLanguage.en ? "Appearance & Theme" : "Външен вид и тема";
  String get settingsCatProcedures => language == AppLanguage.en ? "Procedure Management" : "Управление на процедури";
  String get settingsCatDatabase => language == AppLanguage.en ? "Database Actions" : "Действия с базата данни";
  String get settingsCatSystem => language == AppLanguage.en ? "System Information" : "Системна информация";
  String get settingsCatLanguage => language == AppLanguage.en ? "App Language" : "Език на приложението";
  String get settingsCatStorage => language == AppLanguage.en ? "Storage Management" : "Управление на склада";

  String get settingsAppearanceTitle => language == AppLanguage.en ? "App Theme & Layout" : "Тема и оформление на приложението";
  String get settingsAppearanceSubtitle => language == AppLanguage.en ? "Select a VS Code inspired aesthetics profile to instantly adapt the clinic dashboard." : "Изберете естетически профил, вдъхновен от VS Code, за незабавна адаптация на таблото на клиниката.";
  String get settingsAppearanceLight => language == AppLanguage.en ? "Light Themes" : "Светли теми";
  String get settingsAppearanceDark => language == AppLanguage.en ? "Dark Themes" : "Тъмни теми";

  String get settingsProceduresTitle => language == AppLanguage.en ? "Procedure & Sub-type Management" : "Управление на процедури и подтипове";
  String get settingsProceduresSubtitle => language == AppLanguage.en ? "Manage the available procedure categories and their specific treatment types." : "Управление на наличните категории процедури и техните специфични типове лечение.";
  String get settingsProceduresStep1 => language == AppLanguage.en ? "Step 1: Manage Procedures" : "Стъпка 1: Управление на процедури";
  String get settingsProceduresHint => language == AppLanguage.en ? "New Procedure Name..." : "Име на нова процедура...";
  String get settingsProceduresAdd => language == AppLanguage.en ? "Add Procedure" : "Добави процедура";
  String get settingsProceduresStep2 => language == AppLanguage.en ? "Step 2: Manage Sub-types for" : "Стъпка 2: Управление на подтипове за";
  String get settingsProceduresSubHint => language == AppLanguage.en ? "New Sub-type (e.g. Pain Relief)..." : "Нов подтип (напр. Обезболяване)...";
  String get settingsProceduresAddSub => language == AppLanguage.en ? "Add Sub-type" : "Добави подтип";

  String get settingsStorageTitle => language == AppLanguage.en ? "Storage Categories & Items" : "Категории и артикули в склада";
  String get settingsStorageSubtitle => language == AppLanguage.en ? "Manage available storage categories and specific preset items." : "Управление на наличните категории складове и конкретни артикули.";
  String get settingsStorageStep1 => language == AppLanguage.en ? "Step 1: Manage Categories" : "Стъпка 1: Управление на категории";
  String get settingsStorageHint => language == AppLanguage.en ? "New Category Name..." : "Име на нова категория...";
  String get settingsStorageAdd => language == AppLanguage.en ? "Add Category" : "Добави категория";
  String get settingsStorageStep2 => language == AppLanguage.en ? "Step 2: Manage Items for" : "Стъпка 2: Управление на артикули за";
  String get settingsStorageSubHint => language == AppLanguage.en ? "New Item (e.g. Bandages)..." : "Нов артикул (напр. Бинтове)...";
  String get settingsStorageAddSub => language == AppLanguage.en ? "Add Item" : "Добави артикул";

  String get settingsDatabaseTitle => language == AppLanguage.en ? "Database Factory Reset" : "Фабрично нулиране на базата данни";
  String get settingsDatabaseSubtitle => language == AppLanguage.en ? "Permanently erases all local mock data including Patients, Appointments, and Inventory." : "Постоянно изтрива всички локални тестови данни, включително пациенти, прегледи и инвентар.";
  String get settingsDatabaseDanger => language == AppLanguage.en ? "Danger Zone" : "Опасна зона";
  String get settingsDatabaseIrreversible => language == AppLanguage.en ? "This action is irreversible and will delete all generated records." : "Това действие е необратимо и ще изтрие всички генерирани записи.";
  String get settingsDatabasePurge => language == AppLanguage.en ? "Purge Database" : "Изчистване на базата данни";
  String get settingsDatabaseConfirmTitle => language == AppLanguage.en ? "Confirm Factory Reset" : "Потвърждаване на фабрично нулиране";
  String get settingsDatabaseConfirmBody => language == AppLanguage.en ? "Are you absolutely sure you want to delete all patients, appointments, and inventory? This cannot be undone." : "Сигурни ли сте, че искате да изтриете всички пациенти, прегледи и инвентар? Това действие не може да бъде отменено.";
  String get settingsDatabasePurgeConfirm => language == AppLanguage.en ? "Yes, Purge Everything" : "Да, изчисти всичко";
  String get settingsDatabaseSuccess => language == AppLanguage.en ? "Database successfully purged." : "Базата данни беше изчистена успешно.";

  String get settingsLanguageTitle => language == AppLanguage.en ? "Language Preferences" : "Езикови предпочитания";
  String get settingsLanguageSubtitle => language == AppLanguage.en ? "Choose your preferred language for the clinic management system." : "Изберете предпочитания език за системата за управление на клиниката.";
  String get settingsLanguageEnglish => language == AppLanguage.en ? "English" : "Английски";
  String get settingsLanguageBulgarian => language == AppLanguage.en ? "Bulgarian" : "Български";

  String get settingsSystemVersion => language == AppLanguage.en ? "Version" : "Версия";
  String get settingsSystemUpdated => language == AppLanguage.en ? "Last Updated" : "Последна актуализация";
  String get settingsSystemBackend => language == AppLanguage.en ? "Backend Provider" : "Доставчик на бекенд";
  String get settingsSystemLicense => language == AppLanguage.en ? "License" : "Лиценз";
}

// Extension to easily access translations from context
extension LocalizationExtension on BuildContext {
  Translations l10n(WidgetRef ref) => Translations.of(this, ref);
}
