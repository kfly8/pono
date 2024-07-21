package Stump::Util;
use v5.40;
use utf8;

our $DDFLen = 30;

sub ddf($value) {

    if (!defined $value) {
        return 'Undef';
    }
    elsif (ref $value) {
        no warnings 'once';
        require Data::Dumper;
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Indent = 0;
        local $Data::Dumper::Sortkeys = 1;

        my $str = Data::Dumper::Dumper($value);
        $str = substr($str, 0, $DDFLen) . '...' if length($str) > $DDFLen;
        return "Reference $str";
    }
    else {
        require B;
        my $str = B::perlstring($value);
        return substr($str, 0, $DDFLen) . '...' if length($str) > $DDFLen;
        return $str;
    }
}
