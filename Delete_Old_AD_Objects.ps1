#### Variables ####

$file = "c:\old_ad_objects\old_objects.txt"
$from = "sender@email.com"
$destination = "receiver@email.com"
$subject = "AD objects older than 120 days and disabled have been deleted"
$smtpserver = "smtp.company.com"
$body = "User and computer objects older than 120 days and disabled have been deleted. See the attached file for the distingued names of the deleted objects."

#### Search for disabled accounts in the disabled OUs that are older than 120 days and save them. ####

Search-ADAccount -AccountDisabled | where {$_.lastlogondate -lt (get-date).AddDays(-120) -and ($_.DistinguishedName -like "*Disabled*")} | Select-Object DistinguishedName | ConvertTo-Csv -Delimiter '"' | % {$_ -replace '"', ''} | Select -Skip 2| Out-File "$file" -force

#### Delete these accounts using a FOR loop. ####

foreach ($ADobject in get-content $file) {Remove-ADObject -Identity $ADobject -Confirm:$False}


#### E-mail results ####

send-mailmessage -subject "$subject" -From "$from" -smtpserver "$smtpserver" -body "$body" -To "$destination" -Attachments "$file"

#### Delete test.txt ####

Remove-Item "$file"
