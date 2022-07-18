# Read a .md file, preserve the first seven lines, then convert everything after it from HTML to Markdown by calling /usr/local/bundle/bin/reverse_markdown

use File::Slurp;
our $| = 1;

# Always works in the current directory
foreach my $md_file (glob("*.markdown")) {
	print "\nINFO\tReading $md_file";
	my $raw_content = read_file( $md_file );
	my @split_lines = split(/\n/, $raw_content);
	# Preserve the first seven lines
	# ---
	# layout: post
	# title: Color Me - Blessings from Shri Shirdi Sai Baba
	# joomla_id: 36
	# joomla_url: color-me-blessings-from-shri-shirdi-sai-baba
	# date: 2012-04-24 05:03:51.000000000 +00:00
	# ---
	my @out_lines;
	for (my $i = 0; $i < 7; $i++) {
		push(@out_lines, $split_lines[$i]);
	}
	# Convert the rest of the lines from HTML to Markdown
	my $html = join("\n", @split_lines[7..$#split_lines]);

	# Write the HTML by itself to a file
	my $html_file = $md_file . ".html";
	write_file($html_file, {atomic => 1}, $html);
	print "\nINFO\tWrote $html_file";

	my $markdown_file = $md_file . ".md";

	my $markdown = `/usr/local/bundle/bin/reverse_markdown $html_file > $markdown_file`;

	print "\nINFO\tWrote $markdown_file";

	# Delete the HTML file
	unlink($html_file);
	print "\nINFO\tDeleted $html_file";
	# Read Markdown file
	my $markdown_content = read_file( $markdown_file );

	# Remove any HTML lines
	# First, replace \> with nothing
	# Then remove any lines that start with <(including whitespace ahead of it), or end with >
	$markdown_content =~ s/\>//g;
	$markdown_content =~ s/\s*\<.*\n//g;
	$markdown_content =~ s/.*\>\s+\n*//g;
	# Remove any lines that have DefSemiHidden or LatentStyleCount or UnhideWhenUsed in them
	$markdown_content =~ s/DefSemiHidden=".*"//g;
	$markdown_content =~ s/DefQFormat=".*"//g;
	$markdown_content =~ s/DefPriority=".*"//g;
	$markdown_content =~ s/LatentStyleCount=".*"//g;
	$markdown_content =~ s/UnhideWhenUsed=".*"//g;
	$markdown_content =~ s/QFormat=".*"//g;
	$markdown_content =~ s/Name=".*"//g;

	# Remove any of these lines
	# /* Style Definitions */
	#  table.MsoNormalTable
	# 	{mso-style-name:"Table Normal";
	# 	mso-tstyle-rowband-size:0;
	# 	mso-tstyle-colband-size:0;
	# 	mso-style-noshow:yes;
	# 	mso-style-priority:99;
	# 	mso-style-qformat:yes;
	# 	mso-style-parent:"";
	# 	mso-padding-alt:0in 5.4pt 0in 5.4pt;
	# 	mso-para-margin-top:0in;
	# 	mso-para-margin-right:0in;
	# 	mso-para-margin-bottom:10.0pt;
	# 	mso-para-margin-left:0in;
	# 	line-height:115%;
	# 	mso-pagination:widow-orphan;
	# 	font-size:11.0pt;
	# 	font-family:"Calibri","sans-serif";
	# 	mso-ascii-font-family:Calibri;
	# 	mso-ascii-theme-font:minor-latin;
	# 	mso-fareast-font-family:"Times New Roman";
	# 	mso-fareast-theme-font:minor-fareast;
	# 	mso-hansi-font-family:Calibri;
	# 	mso-hansi-theme-font:minor-latin;}
	$markdown_content =~ s/\/\* Style Definitions \*\///g;
	$markdown_content =~ s/\s*table.MsoNormalTable//g;
	$markdown_content =~ s/\s*\{mso-style-name:.*;//g;
	$markdown_content =~ s/\s*mso-tstyle-rowband-size:.*;//g;
	$markdown_content =~ s/\s*mso-tstyle-colband-size:.*;//g;
	$markdown_content =~ s/\s*mso-style-noshow:.*;//g;
	$markdown_content =~ s/\s*mso-style-priority:.*;//g;
	$markdown_content =~ s/\s*mso-style-qformat:.*;//g;
	$markdown_content =~ s/\s*mso-style-parent:.*;//g;
	$markdown_content =~ s/\s*mso-padding-alt:.*;//g;
	$markdown_content =~ s/\s*mso-para-margin-top:.*;//g;
	$markdown_content =~ s/\s*mso-para-margin-right:.*;//g;
	$markdown_content =~ s/\s*mso-para-margin-bottom:.*;//g;
	$markdown_content =~ s/\s*mso-para-margin-left:.*;//g;
	$markdown_content =~ s/\s*line-height:.*;//g;
	$markdown_content =~ s/\s*mso-pagination:.*;//g;
	$markdown_content =~ s/\s*mso-ascii-font-family:.*;//g;
	$markdown_content =~ s/\s*mso-ascii-theme-font:.*;//g;
	$markdown_content =~ s/\s*mso-fareast-font-family:.*;//g;
	$markdown_content =~ s/\s*mso-fareast-theme-font:.*;//g;
	$markdown_content =~ s/\s*mso-hansi-font-family:.*;//g;
	$markdown_content =~ s/\s*mso-hansi-theme-font:.*;\}//g;	
	$markdown_content =~ s/\s*font-size:.*;//g;
	$markdown_content =~ s/\s*font-family:.*;//g;
	$markdown_content =~ s/  \/  //g;
	$markdown_content =~ s/  \///g;
	$markdown_content =~ s/&nbsp;//g;

	# Remove successive newlines
	$markdown_content =~ s/\n\n/\n/g;
	$markdown_content =~ s/\r\n\r\n/\r\n/g;
	$markdown_content =~ s/\n\n/\n/g;
	$markdown_content =~ s/\r\n\r\n/\r\n/g;
	$markdown_content =~ s/\n\n/\n/g;
	$markdown_content =~ s/\r\n\r\n/\r\n/g;
	$markdown_content =~ s/\n\n/\n/g;
	$markdown_content =~ s/\r\n\r\n/\r\n/g;
	$markdown_content =~ s/\n\n/\n/g;
	$markdown_content =~ s/\r\n\r\n/\r\n/g;

	# Remove lines with just spaces or tabs on them
	$markdown_content =~ s/^\s*\n//g;
	$markdown_content =~ s/^\t*\n//g;
	$markdown_content =~ s/\n\n/\n/g;
	$markdown_content =~ s/\r\n\r\n/\r\n/g;
	$markdown_content =~ s/^\s*\n//g;
	$markdown_content =~ s/^\t*\n//g;
	$markdown_content =~ s/\n\n/\n/g;
	$markdown_content =~ s/\r\n\r\n/\r\n/g;

	push(@out_lines, $markdown_content);
	my $out_content = join("\n", @out_lines);

	my $out_file = $md_file . ".out";
	print "\nINFO\tWriting $out_file ... ";
	# Overwrite the file atomically using File::Slurp
	write_file( $out_file, {atomic => 1}, $out_content );
	print "Done";

	# Delete the .md and .html file
	# Move the .out file to the .md file
	unlink($md_file);
	unlink($html_file);
	unlink($markdown_file);
	rename($out_file, $md_file);
	# print "\nINFO\tDeleted $md_file and $html_file";
	print "\nINFO\tRenamed $out_file to $md_file";

}
print "\nINFO\tDone\n";
exit(0);
