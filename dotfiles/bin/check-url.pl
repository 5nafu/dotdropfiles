#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use Digest::MD5 'md5_hex';
use Time::HiRes qw( gettimeofday tv_interval );

my $count = 23;
my( @cred, $dns );

my $parsed = 0;
while( @ARGV and not $parsed ){
  if( $ARGV[0] =~ m/^\d+$/ ){
    $count = shift @ARGV;
  }elsif( @ARGV > 1 and $ARGV[0] =~ m/:/ ){
    @cred = split /:/, shift @ARGV, 2;
  }elsif( $ARGV[0] =~ m/^([\w.]*)$/ ){
    $dns = shift @ARGV;
  }else{
    $parsed = 1;
  }
}

@ARGV or die "usage: $0 [number of tries] [realm:user:password] [dns] url\n";

if( @cred ){
  my $host_port = $ARGV[0];
  $host_port =~ s@.*//@@;
  $host_port =~ s@/.*@@;
  if( $host_port !~ m@:@ ){
    $host_port .= ( $ARGV[0] =~ m@^http:@ ? ':80' : ':443' );
  }
  unshift @cred, $host_port;
  print "credentials: @cred\n\n";
}

while( $count-- gt 0 ){
  my $timestamp = [ gettimeofday ];
  my $ua = LWP::UserAgent->new;
  @cred and $ua->credentials( @cred );
  if( $LWP::VERSION >= 6 ){
    $ua->ssl_opts( verify_hostname => 0 );
  }
  my $req = HTTP::Request->new( GET => $ARGV[0] );
  $dns and $req->header( host => $dns );
  my $get = $ua->request( $req );

  my $content = ( $get->content or '' );
  my $content_md5 = md5_hex $content;

  if( not $get->is_success or not %{$get->headers} ) {
    $content =~ s!<[^>]+>!!g;
    $content =~ s!\s+! !mg;
    printf "%03d: %s = %s: %s\n",
           $count, $content_md5, $get->status_line, $content;
  }else{
    printf "%03d: %s = %s",
           $count, $content_md5, $get->status_line;
  }

  $get->base eq $ARGV[0] or printf " [%s]", $get->base;

  # sort keys %{$get->headers}
  my %format = ( 'Content-Length' => ', %s bytes', default => ', %s' );
  foreach my $header (qw( Content-Length Last-Modified Set-Cookie Warning )){
    if( $get->header( $header ) ){
      my $value = $get->header( $header );
      if( $header eq 'Last-Modified' ){
        $value =~ s/^\w{3}, //;
        $value =~ s/ GMT$//;
      }elsif( $header eq 'Set-Cookie' ){
        $value =~ s/.*\.jvm_([^;]+);.*/$1/;
      }
      printf( ( $format{$header} or $format{default} ), $value );
    }
  }
  printf " [%.3fs]\n", tv_interval $timestamp;
}
