#usage perl countldap.pl zj
use Net::LDAP;

$DN = $ARGV[0]; #从命令行参数中获取下级目录名
$base = "dc=ctc,dc=com";  #设定base
$ldap = Net::LDAP->new("192.168.61.128", port=>2389, timeout=>30);
$ldap->bind(("cn=root"), password=>"password");
#$mesg = $ldap->search(base=>$DN.",".$base,filter=>"(uid=65040021\@xj)");
#获取org和user
$org = $ldap->search(base=>"cn=organizations,dc=".$DN.",".$base,scope=>"sub", sizelimit=>100000, filter=>"(&(objectClass=organizationalUnit))"); #.拼接字符串
$user = $ldap->search(base=>"cn=users,dc=".$DN.",".$base,scope=>"sub", sizelimit=>100000, filter=>"(&(objectClass=person))"); 

##@entries = $mesg->entries;
##foreach $entry(@entries){
##$entry->dump;
##}

#输出统计出的数量
print "org: ".$org->count()." user: ".$user->count()."\n";
