#usage perl countldap.pl zj
use Net::LDAP;

$DN = $ARGV[0];
$base = "dc=ctc,dc=com";
$ldap = Net::LDAP->new("192.168.61.128", port=>2389, timeout=>30);
$ldap->bind(("cn=root"), password=>"password");
#$mesg = $ldap->search(base=>$DN.",".$base,filter=>"(uid=65040021\@xj)");
$org = $ldap->search(base=>"cn=organizations,dc=".$DN.",".$base,scope=>"sub", sizelimit=>100000, filter=>"(&(objectClass=organizationalUnit))"); #.拼接字符串
$user = $ldap->search(base=>"cn=users,dc=".$DN.",".$base,scope=>"sub", sizelimit=>100000, filter=>"(&(objectClass=person))"); 

##@entries = $mesg->entries;
##foreach $entry(@entries){
##$entry->dump;
##}

print "org: ".$org->count()." user: ".$user->count()."\n";
