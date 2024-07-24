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
    $vcard_output .= "TEL;WORK;VOICE:$company_phone\n" if $company_phone;
    $vcard_output .= "TEL;CELL;VOICE:$phone\n" if $phone;
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
    my $signature_html = qq{
    <table style="font-family: Arial; font-size: 14px; color: #000;" border="0" cellspacing="0" cellpadding="0" data-darkreader-inline-color="">
<tbody>
<tr>
<td>
<h2 style="margin: 0; font-size: 18px; font-weight: 600;">$name</h2>
<p style="margin: 0; font-size: 16px;">Debt Consultant</p>
<p style="margin: 0; font-size: 16px;">Iconic Debt Relief | Debt Relief</p>
</td>
</tr>
<tr>
<td><img src="https://lh3.googleusercontent.com/drive-viewer/AKGpihYat9OdFE_8I-QsCeO5sbdlTPK8er3gWz_mz2Un3v9tAZsYfbbALRCbKwNxkos5h_54uwN26SvGRB7inP03tpoGOcnyhdfuGI8=s2560" alt="Company Logo" width="130" /></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="https://cdn2.hubspot.net/hubfs/53/tools/email-signature-generator/icons/phone-icon-2x.png" alt="Phone Icon" width="12" /> </span> <a style="text-decoration: none; color: #000;" href="tel:$phone" data-darkreader-inline-color="">$phone_formatted</a></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="https://cdn2.hubspot.net/hubfs/53/tools/email-signature-generator/icons/email-icon-2x.png" alt="Email Icon" width="12" /> </span> <a style="text-decoration: none; color: #000;" href="mailto:$email" data-darkreader-inline-color="">$email</a></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="https://lh3.googleusercontent.com/drive-viewer/AKGpihay20PEcdVyKr6-GOW8DzgGSaO_qHMI3P9ruX5_Cr67VzU6QlFSsETRF9FaPgKoyeCtyZ8gzwIf1VkIYMNu1mR44xC4nU3Ecw=s2560" alt="Contact Icon" width="15" /> </span> <a style="text-decoration: none; color: #000;" href="https://drive.google.com/uc?export=download&id=[placeholder]" data-darkreader-inline-color=""> Click here to Download Contact Card </a></td>
</tr>
<tr>
<td style="font-size: 12px;"><span style="padding: 3px; border-radius: 3px;"> <img style="vertical-align: middle;" src="https://lh3.googleusercontent.com/drive-viewer/AKGpihY4DwOh4Uw5VCCC2hUWAYoUcTje3VgmWUek1doF-9GrPFokLP2YOiX7dA0ckp8jETWvHa3fpk7BOA3nIMT59WJNEDdsVsu5Trc=s2560" alt="Social Media Icon" width="20" /> </span> <a style="text-decoration: none; color: #000;" href="https://www.facebook.com/profile.php?id=100091661963733" data-darkreader-inline-color="">Follow us in facebook! <span> (Click Here)</span></a></td>
</tr>
<tr>
<td>
<p style="font-size: 10px; color: #777;" data-darkreader-inline-color="">This communication is confidential and does not necessarily represent the views of Iconic Debt Relief. It is intended solely for those named above as recipients. If you have received this in error please notify us and delete this message. Thank you.</p>
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
