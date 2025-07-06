use v5.42;
use utf8;
use experimental qw(class);

class Pono::Request::Upload {
    field $headers  :param :reader;
    field $tempname :param :reader;
    field $size     :param :reader;
    field $filename :param :reader;
    field $basename;

    method path() { $tempname }
    method content_type { $headers->content_type(@_) }

    method basename() {
        unless (defined $basename) {
            require File::Spec::Unix;
            my $bn = $filename;
            $bn =~ s|\\|/|g;
            $bn = ( File::Spec::Unix->splitpath($basename) )[2];
            $bn =~ s|[^\w\.-]+|_|g;
            $basename = $bn;
        }
        $basename;
    }
}
