use Test::More tests => 7;

BEGIN { 
    use_ok( 'File::Find::Rule::SAUCE' );
}

my $dir = 't/data';

my @expected_1 = ( );

my @expected_2 = (
	"$dir/test.dat"
);

my @expected_3 = (
	"$dir/test_no_comments.dat"
);

my @files;

@files = find( sauce => { comments => 'bogus' }, in => $dir );
ok( compare_arrays( \@files, \@expected_1 ), "comments => 'bogus'" );

@files = find( sauce => { comments => qr/bogus/ }, in => $dir );
ok( compare_arrays( \@files, \@expected_1 ), 'comments => qr/bogus/' );

@files = find( sauce => { comments => 'Test Comment' }, in => $dir );
ok( compare_arrays( \@files, \@expected_2 ), "comments => 'Test Comment'" );

@files = find( sauce => { comments => qr/Test/ }, in => $dir );
ok( compare_arrays( \@files, \@expected_2 ), 'comments => qr/Test/' );

@files = find( sauce => { comments => '' }, in => $dir );
ok( compare_arrays( \@files, \@expected_3 ), "comments => ''" );

@files = find( sauce => { comments => qr/^$/ }, in => $dir );
ok( compare_arrays( \@files, \@expected_3 ), 'comments => qr/^$/' );

sub compare_arrays {
	my ($first, $second) = @_;
	return 0 if @$first != @$second;
	my $i = 0;
	$second->[$i++] ne $_ && return 0 for @$first;
	return 1;
}  