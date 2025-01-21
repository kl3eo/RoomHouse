#!/usr/bin/perl
#use 5.006;
use CGI;

my $query = new CGI;

print qq{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<head><title>DEMO</title></head><body style="background:#ddd;text-align:center;">};

print qq{<div style="width:360px;margin:60px auto;font-size:24px;">This is DEMO mode.<br>No USERS operations.</div>};

print qq{</body></html>};
exit;

