#计算o公司下的人员(即以该公司为主职和兼职的人员)，并将结果写入一个excel。人员可能有重复，得筛选过。
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use Spreadsheet::ParseExcel::FmtUnicode;
 
my $parser = Spreadsheet::ParseExcel->new();
#防止中文乱码
my $formatter = Spreadsheet::ParseExcel::FmtUnicode->new(Unicode_Map=>"CP936"); 
my $workbook = $parser->parse('hquser3618.xls', $formatter);	
my $outworkbook = Spreadsheet::WriteExcel->new('out.xls'); #新增一个供写入的excel
my $outworksheet = $outworkbook->add_worksheet(); #新建sheet
my %hash;  #用于记录公司下已统计的人员数的hash表
my %index; #用于记录已写入的列数的hash表，即公司数
my $index_value = 0; #列数的值默认为0
         
if ( !defined $workbook ) 
{
	die $parser->error(), ".\n";
}
         
for my $worksheet ( $workbook->worksheets() ) 
{
 
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();


	#去除前两行无用的数据
    for my $row ( $row_min+2 .. $row_max )
	{			
		my $oids = $worksheet->get_cell( $row, 38 ); #获取主职所在公司的id
		my $uid = $worksheet->get_cell( $row, 17 );  #获取用户的id
        next unless $oids; #oid为空则跳过循环余下内容
		my @tmp = split(/,/, $oids->value());
		my $oid = $tmp[0];  #获得"ou=xxx" 这样的格式
		
		if (exists $hash{$oid})
		{
			$hash{$oid}++; #公司下的人数增加1
		}
		else
		{
			$hash{$oid} = 1; #公司下的人数设为1
			$index{$oid} = $index_value; #储存公司的所在的列数
			$index_value ++; #自增，指向下一列
			$outworksheet->write(0,$index{$oid}, $oid);  #如果是第一次出现，在第一行相应位置写入所在公司的值
		}			
		$outworksheet->write($hash{$oid},$index{$oid},$uid->value()); #将uid写入相应公司的所在的列下
					 
                
    }

	
	for my $row ( $row_min+2 .. $row_max )
	{
		my $poids = $worksheet->get_cell( $row, 4);  #获取兼职所在公司的id
		my $uid = $worksheet->get_cell ($row, 17);	#获取用户id
		next unless $poids; #poids为空则跳过循环余下内容
		
		#print $poids->value();
		@poid = split(/,/, $poids->value());	#兼职可能有多个，以逗号分割
		while(($i,$v) = each @poid)
		{
			$v = "ou=".$v; #给ouid前加“ou="
			if (exists $hash{$v})
			{
				$hash{$v}++; #公司下的人数增加1
			}
			else
			{
				$hash{$v} = 1; #公司下的人数设为1
				$index{$v} = $index_value; #储存公司的所在的列数
				$index_value ++; #自增，指向下一列
				$outworksheet->write(0,$index{$v},$v);  #如果是第一次出现，在第一行相应位置写入所在公司的值
			}	
			$outworksheet->write($hash{$v},$index{$v},"-".$uid->value()); #将uid写入相应公司的所在的列下,兼职人员前加-以区分
		}
	}
	#输出所有公司下的人数
=pod
	while(($k, $v) = each %hash)
		{
			print "$k = $v\n";
		}
=cut
}
