use strict;
use warnings;
use Text::CSV;
use MIME::Base64;
use File::Slurp qw(read_file write_file);

# Path to the CSV file
my $csv_file_path = 'signatures.csv';

# Read the CSV file
my $csv = Text::CSV->new({ binary => 1, auto_diag => 1 });
open my $fh, '<', $csv_file_path or die "Could not open '$csv_file_path' $!\n";
my $headers = $csv->getline($fh);
$csv->column_names(@$headers);

my $company_name = 'Iconic Debt Relief';
my $job_title = 'Debt Consultant';
my $company_website = 'https://www.iconicdebtrelief.com/';
my $company_phone = '(480) 885-8419';

# Iterate through each row in the CSV
while (my $row = $csv->getline_hr($fh)) {
    my $name = $row->{Name};
    my $email = $row->{Email};
    my $phone = $row->{Phone};

    # Create a vCard manually
    my $vcard_output = "BEGIN:VCARD\n";
    $vcard_output .= "VERSION:2.1\n";
    if ($name) {
        my ($first_name, $last_name) = split ' ', $name, 2;
        $last_name //= ''; # Ensure last_name is defined
        $first_name //= ''; # Ensure first_name is defined
        $vcard_output .= "N:$last_name;$first_name;;;\n";
        $vcard_output .= "FN:$name\n";
    }
    $vcard_output .= "EMAIL;PREF;INTERNET:$email\n" if $email;
    $vcard_output .= "ORG:$company_name\n" if $company_name;
    $vcard_output .= "TITLE:$job_title\n" if $job_title;
    $vcard_output .= "TEL;BUSINESS;VOICE:$company_phone\n" if $company_phone;
    $vcard_output .= "TEL;WORK;VOICE:$phone\n" if $phone;
    $vcard_output .= "X-MS-TEL;VOICE;COMPANY:$company_phone\n" if $company_phone;
    $vcard_output .= "URL;WORK:$company_website\n" if $company_website;
    $vcard_output .= "END:VCARD\n";

    # Save the vCard to a file
    my $vcard_file_path = "vcard_$name.vcf";
    write_file($vcard_file_path, $vcard_output);

    # Encode the vCard as a Base64 data URI
    my $vcard_base64 = encode_base64($vcard_output);
    $vcard_base64 =~ s/\s+//g; # Remove any whitespace from the Base64 string
    my $vcard_data_uri = 'data:text/vcard;base64,' . $vcard_base64;

    # Format phone number for HTML
    my $phone_formatted = $phone;
    $phone_formatted =~ s/(\d{3})(\d{3})(\d{4})/($1) $2-$3/;

    # Generate HTML signature
    my $signature_html = qq{<table style="font-family: Arial; font-size: 14px; color: #000;" border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<h2 style="margin: 0; font-size: 18px; font-weight: 600; color: #0093D9;">$name</h2>
<p style="margin: 0; font-size: 16px; color: #0093D9;">Debt Consultant</p>
<p style="margin: 0; font-size: 16px; color: #0093D9;">Iconic Debt Relief</p>
</td>
</tr>
<tr>
<td><img src="data:image/png;base64,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" alt="Company Logo" width="130" /></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="https://cdn2.hubspot.net/hubfs/53/tools/email-signature-generator/icons/phone-icon-2x.png" alt="Phone Icon" width="12" /> </span> <a style="text-decoration: none; color: #0093D9;" href="tel:$phone" data-darkreader-inline-color="">$phone_formatted</a></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="https://cdn2.hubspot.net/hubfs/53/tools/email-signature-generator/icons/email-icon-2x.png" alt="Email Icon" width="12" /> </span> <a style="text-decoration: none; color: #0093D9;" href="mailto:$email" data-darkreader-inline-color="">$email</a></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA8AAAAPCAYAAAA71pVKAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAGKSURBVDhPpZM7SwNBFIXPTnZNouSpKEJEhYBIQFDRnyB2PnoL0UIQBMHWQmwFK8FOUGxNCgv/gxDRQhshiIgSY6KoSTTrrnMmD8MaYuHX3Lkz99yZuXNHsyWoYFpA4qyIeLKA81sTLwULAa/AUI+O2REvpoc90EUlWFITX6dNLB284OreVAuNGOzWsTsXQLRTV74SUzizk0P2XW79B+E2gfhySCUQPCp3dAqDrQITMbey9TCO8dQJ3tF5VN7reCWMvfmgsvX3JIynThzJ4jjxe4D+Dpca09J3Qp24kFV1ks3b2Erc4faxqCx9J9RpkbUH2/q9Br/bQntLEZlPD14/HOeWCE1WO7aetnP5n2INRQxsTPkw1mdAkwHMm7wpYfP4FaepUjlIEpKFFGyAKgzcXwhivL8sJDSjvQYOF0NwG5VJCXWCnVOP29X4rQ2XDaHSl6FOK33Z9uT2U+25or43DHT97FAllbFw+exTY3bayWr7PzuMExxwghmbwfWqkDT8VWwAvmPzXwV8A0ZStQ6SfgVMAAAAAElFTkSuQmCC" alt="Contact Icon" width="15" /> </span> <a style="text-decoration: none; color: #0093D9;" href="https://drive.google.com/uc?export=download&id=[placeholder]" data-darkreader-inline-color=""> Click here to Download Contact Card </a></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAGjSURBVDhPrZTPLwNBFMe/b7aqijbEj/bgRCJxk7g6OUocpAlXB2cOgqMLB5WIxKEX/Qf05kZwlggHiQQHRILIRlJKu9vuPjOskHZZtv0km9l5M/Od92PyqH0mF9OEvcjgBBFF4ANm1omQNmAtUWz2aQPEE4A0VQOzbQNJIcdE1WIKIkFsTwoS4k9hRhsIvZ0CfXGBnnaBhmClDyS0VorNPbEz/5HBngAWhusRjxI0AZglYHqzgN0z+VOGXP6dbunN+ljo3bOWMCESIrQ1EUJ1zoYyPAWHegPoaP4IL19kZI6KWN42cf4gS+CCp6DK1ydbJyVMyVBX9wxc+BUMfNtxpTNsj4x7Cv4X1yr3d2nITIYRDjqGMl4MxkjqFad3lWH78jBbYDwXnEkZroLKg+MbC4fXFvTcVwC3WX63HVxayObdk+kasnokQl6lxuRoCOMDH49uZcfE2r4BdcByL7K7h58HSvLjb9epCivbT2KKmle5xoIMIRur7syqRjbaeyETn1bN0bH5h2EyactCtW2plpTJf3SW/omMke17m2g+aDam3gDlv54ykkL9JwAAAABJRU5ErkJggg==" alt="Social Media Icon" width="20" /> </span> <a style="text-decoration: none; color: #0093D9;" href="https://www.facebook.com/profile.php?id=100091661963733" data-darkreader-inline-color="">Follow us in facebook! <span> (Click Here)</span></a></td>
</tr>
<tr>
<td>
<p style="font-size: 10px; color: #777777;" data-darkreader-inline-color="">This communication is confidential and does not necessarily represent the views of Iconic Debt Relief. It is intended solely for those named above as recipients. If you have received this in error please notify us and delete this message. Thank you.</p>
</td>
</tr>
</tbody>
</table>
    };

    # Save the HTML signature to a file
    my $signature_file_path = "signature_$name.html";
    write_file($signature_file_path, $signature_html);
}

close $fh;

print "Signatures and vCards generated successfully!\n";
