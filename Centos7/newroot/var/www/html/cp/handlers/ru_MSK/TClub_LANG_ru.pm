package TClub_LANG_ru;
use 5.006;

use strict;
use CGI;

require Exporter;

my $scriptURL = CGI::url();
my $tmm = 0;
$tmm = 1 if ($scriptURL =~ /tennismatchmachine\.com/);

#$scriptURL =~ /:(\d+)/
#our $other_posrt = ":".$1;

our $scriptURL_tmm = 'http://tennismatchmachine.com/cgi/ru/tclub';

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
%lang_list %loco_list %guessed_loco_list @weekday @weekday_abbr @dtime $language $__69 $__70 $__71 $__71a $__72 $__73 $__73a $__73b $__74 $__75 $__76 $__76a $__76b $__83 $__84 $__84c $__84f
$__84e $__84g $__84h $__88 $__89 $__90 $__91 $__93 $__94a $__96 $__96a $__96b $__97 $__98 $__99 $__99a $__99b $__99bb $__99d $__99dd 
$__99e $__99ee $__99f $__99ff  $__99g $__99gg $__99h $__99hh $__99i $__99ii $__99j $__99jj $__99k $__99kk 
$__100 $__101 $__102 $__103 $__104  $__105 $__106 
$__93_1 $__96_1 $__96a_1 $__96b_1 $regbutton $scriptURL_tmm $__107 $__108);

our %lang_list = %lang_list = ('ru'=>'Русский',
	      'en'=>'English',
	      'fr'=>'franц�ais',
	      'tr'=>'Tц�rkц�e',
	      'rs'=>'Српски',
	      'cr'=>'Hrvatski',
	      'es'=>'Espaц�ol'
);	  
	   
our %loco_list = ('ru'=>'Москва',
'ru_KLG'=>'Калуга',
'ua_KJV'=>'Киев',
#'ru_VRN'=>'Воронеж',
#'ru_RND'=>'Таганрог',
#'ru_RLX'=>'Office',
#'ru_BRL'=>'BAR',
#'ru_ADL'=>'Адлер',
#'ru_TVR'=>'Тверь',
#'ru_KZN'=>'Казань',
#'ru_NZN'=>'Н.Новгород',
#'ru_NSK'=>'Новосибирск',
#'ru_SMR'=>'Самара',
#'ru_VLG'=>'Волгоград',
#'ru_SPB'=>'С.Петербург',
#'ru_MKH'=>'Махачкала',
#'ru_YKB'=>'Екатеринбург',
#'ua_KHV'=>'Харьков',
#'ua_DSK'=>'Донецк',
#'by_MYN'=>'Минск',
#'ru_VVK'=>'Владивосток',
#'rs_BGR'=>'Белград',
#'RUCUBE'=>'RUCUBE',
);

our %guessed_loco_list = ('ru'=>'Moscow','ru_MSK'=>'Moscow','ru_THR'=>'Moscow',
'ru_KLG'=>'Kaluga',
'ua_KJV'=>'Kiev',
'ru_VRN'=>'Voronezh',
'ru_RND'=>'Rostov-na-donu',
'ru_KZN'=>'Kazan',
'ru_ADL'=>'Sochi',
'ru_TVR'=>'Tver',
'ru_NZN'=>'Nizhniy Novgorod',
'ru_NSK'=>'Novosibirsk',
'ru_SPB'=>'Saint Petersburg',
'ru_VLG'=>'Volgograd',
'ru_SMR'=>'Samara',
'ru_VVK'=>'Vladivostok',
'ru_YKB'=>'Yekaterinburg',
'ru_MKH'=>'Mahachkala',
'ua_KHV'=>'Kharkov',
'ua_DSK'=>'Donetsk',
'by_MYN'=>'Minsk',
'rs_BGR'=>'Belgrade'
);
	      
our $language = "russian";

	      
our @weekday = ('воскресенье', 'понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота');
our @weekday_abbr = ('вск', 'пнд', 'вт', 'ср', 'чт', 'пт', 'сб');
our @dtime = ('ночь', 'утро', 'день', 'вечер');

our $__69="Набранные пароли не совпадают или короче 8 символов!";
our $__70="Введите логин и пароль длиной не менее 8 символов!";
our $__71="Наберите 4-букв. код --  символы могут быть 0123456789abcdef";
our $__71a="Введите название города";
our $__72="Пользователь с таким именем уже существует!<br>Пожалуйста, придумайте другой логин!";
our $__73="заполните все поля и нажмите кнопку \"GO!\"";
our $__73a="<br><br><b>Введите тот же email, что в Вашем профиле:</b><br>";
our $__73b="<br><br><b>Введите свой email и новый город:</b><br>";
our $__74="Вход";
our $__75="<small>Логин:</small>";
our $__76="<small>Пароль:</small>";
our $__76a="<small>Запомнить</small>";
our $__76b="<small>Сохранять</small>";
#our $__83="Пароль или имя набраны неверно<br> Внимание, если проблема появилась 13.07.2011 и вы не можете зайти под своим старым паролем после нескольких попыток, напишите на info\@motivation.ru!";
our $__83="Пароль или имя набраны неверно";
our $__84="Регистрация";
our $__84e="Вход в клуб ";
our $__84c="Забыли пароль?";
our $__84f="Создайте новый клуб";
our $__84g="Найдите свой клуб - см. \"Другие\"";
our $__84h="Вы в другом городе? см. <a style=\"text-decoration:none;\" href=$scriptURL?Submit=Logout>здесь</a>";
our $__88="Вернуться в начало";
our $__89="..секундочку..";
our $__90="Отсутствует имя пользователя.";
our $__91="Отсутствует пароль.";
our $__93="<a href=/docs/contacts_tclub.ru.html target=new><small>Контакты</small></a>";
our $__94a="<a href=/docs/tos.ru.html target=new><small>Условия</small></a>";
our $__96="<a href=/docs/about_tclub.ru.html target=new><small>О программе</small></a>";
our $__96a="<a href=/docs/tclub.html target=new><small>Что это такое?</small></a>";
our $__96b="<a href=javascript:window.guest()><small>Витрина</small></a>";

our $__93_1="<a href=# onclick=\"document.getElementById('Contacts').style.display='block';document.getElementById('About').style.display='none';document.getElementById('Guests').style.display='none';\"><small>Контакты</small></a>";
our $__96_1="Это онлайновая программа для любителей тенниса. Подробнее см. <a href=/docs/tclub.html target=new>здесь</a>";
our $__96a_1="<a href=# onclick=\"document.getElementById('Contacts').style.display='none';document.getElementById('About').style.display='block';document.getElementById('Guests').style.display='none';\"><small>Что это такое?</small></a>";
our $__96b_1="<a href=$scriptURL?mode=demo><small>Витрина</small></a>";


our $__97="<small>(C) 2006-2013</small>";
our $__98="Внимание! Пароль и имя будут стерты из памяти. Вы уверены, что сможете вспомнить пароль?";
our $__99="Для работы необходимо включить поддержку Cookies в настройках Вашего браузера!";
our $__99a="Временно не работает";

our $__99b="Поиск партнеров по теннису, теннис в Москве, теннисные корты, теннисный форум";
our $__99bb="Сайт для поиска партнеров по теннису, теннис в Москве, теннисные корты, теннисный форум";

our $__99d="знакомства, культурный досуг, отдых, совместные экскурсии, мероприятия, круг общения";
our $__99dd="Сайт для знакомства, культурного досуга, отдыха, совместных экскурсий, мероприятий";

our $__99e="онлайн аукционы";
our $__99ee="Сайт для онлайн аукционов";

our $__99f="агрегатор пиццы";
our $__99ff=$__99f;

our $__99g="пакетные туры, индивидуальные туры";
our $__99gg=$__99g;

our $__99h="все предложения в вашем районе: ремонт и настройка компьютера и др.";
our $__99hh="сайт для всех, кто живет рядом";

our $__99i="сайт про лузеров";
our $__99ii="сайт про лузеров";

our $__99j="джазовые стандарты";
our $__99jj="сайт для тех, кто играет джаз";

our $__99k="AI-счeтчики";
our $__99kk="сайт для тех, кто любит всe считать";

our $nast="сайт для настоящей борьбы с одиночеством и скукой";

our $__100 = "дерзайн";
our $__101 = "В браузере не включена поддержка Javascript!";
our $__102 = "Логин";
our $__103 = "Пароль";
our $__104 = "Другие города";
our $__105 = "<a href=\"javascript:writeCookie('MOBILE','1');location.reload();\"><small>PDA-версия</small></a>";
our $__106 = "-- выбрать";
our $regbutton = "Register";

our $__107 = "11 лет<br>Клуба";
our $__108 = "подтвердить";
1;
__END__
