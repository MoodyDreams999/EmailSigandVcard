<?php
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['csv_file'])) {
    $upload_dir = 'uploads/';
    $upload_file = $upload_dir . basename($_FILES['csv_file']['name']);

    // Create the uploads directory if it doesn't exist
    if (!file_exists($upload_dir)) {
        mkdir($upload_dir, 0777, true);
    }

    // Move the uploaded file to the uploads directory
    if (move_uploaded_file($_FILES['csv_file']['tmp_name'], $upload_file)) {
        // Path to the Perl script
        $perl_script = 'path/to/your/perl_script.pl';

        // Execute the Perl script with the uploaded CSV file
        $command = "perl $perl_script $upload_file";
        $output = shell_exec($command);

        echo "<pre>$output</pre>";
    } else {
        echo "Error uploading the file.";
    }
} else {
    echo "Invalid request.";
}
?>
