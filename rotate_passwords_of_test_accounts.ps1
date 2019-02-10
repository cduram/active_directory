# Variables

$testusers = ("testuser1", "testuser2")


# Change test user passwords to random values.

foreach ($user in $testusers){

function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}

function Scramble-String([string]$inputString){
    $characterArray = $inputString.ToCharArray()
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length
    $outputString = -join $scrambledStringArray
    return $outputString
}

$password = Get-RandomCharacters -length 10 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 10 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 5 -characters '0123456789'
$password += Get-RandomCharacters -length 1 -characters '!"§$%&/()=?}][{@#*+'

$password = Scramble-String $password

Write-Host $password

Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)

}

# Remove any groups assigned to test users.

foreach ($user in $testusers){

Get-ADUser -Identity $user -Properties MemberOf | ForEach-Object {
  $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false
}

}

# Move Test Users to their OU

foreach ($user in $testusers){
Get-ADUser -Identity $user | Move-ADObject -TargetPath 'OU=Test Accounts,DC=foo,DC=com'
}
