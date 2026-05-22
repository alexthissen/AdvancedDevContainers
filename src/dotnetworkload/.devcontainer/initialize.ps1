# Set password to environment variable or fallback to default
$password = if ([string]::IsNullOrEmpty($args[0])) { "DefaultPassword!" } else { $args[0] }

# Derive PFX filename from the workspace folder name
$workspaceName = Split-Path -Leaf (Get-Location)
$pfxFileName = "$workspaceName-ssl.pfx"

# Export ASP.NET Core development certificate to PFX file in mount directory
dotnet dev-certs https --export-path $HOME/.aspnet/https/$pfxFileName --password $password --verbose