#!perl
use lib qw(../lib);
use File::Basename;
use Plack::Builder;
use Plack::App::Directory;
use Plack::App::Vim;

my $dir = dirname __FILE__;
builder {
    mount "/static" => Plack::App::Directory->new({root => "$dir/static"});
	mount "/" => Plack::App::Vim->new({server => 'VIM'});
};
