# Module PowerShell pour la gestion d'Active Directory
# Ce module contient des fonctions simples pour gérer les utilisateurs dans AD.

# Importer le module Active Directory (nécessaire pour interagir avec AD)
# Assurez-vous que le module ActiveDirectory est installé sur votre serveur (RSAT-AD-PowerShell)
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Vérifier si le module Active Directory est disponible
if (-not (Get-Module -Name ActiveDirectory)) {
    Write-Error "Le module ActiveDirectory n'est pas disponible. Installez les outils RSAT pour Active Directory."
    return
}

# Fonction 1 : Créer un nouvel utilisateur dans Active Directory
function New-ADUserAccount {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FirstName,  # Prénom de l'utilisateur

        [Parameter(Mandatory=$true)]
        [string]$LastName,   # Nom de famille de l'utilisateur

        [Parameter(Mandatory=$true)]
        [SecureString]$Password,   # Mot de passe de l'utilisateur

        [Parameter(Mandatory=$true)]
        [string]$OU          # Unité d'organisation (OU) où créer l'utilisateur (ex. "OU=Users,DC=domaine,DC=com")
    )

    # Construire le nom d'utilisateur (par exemple, prenom.nom)
    $UserName = "$FirstName.$LastName"
    
    # Construire le nom complet
    $FullName = "$FirstName $LastName"

    try {
        # Créer l'utilisateur avec les paramètres fournis
        New-ADUser -Name $FullName `
                   -SamAccountName $UserName `
                   -UserPrincipalName "$UserName@domaine.com" `
                   -GivenName $FirstName `
                   -Surname $LastName `
                   -Path $OU `
                   -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
                   -Enabled $true `
                   -PasswordNeverExpires $false `
                   -ChangePasswordAtLogon $true

        Write-Output "Utilisateur $FullName créé avec succès dans $OU."
    }
    catch {
        Write-Error "Erreur lors de la création de l'utilisateur : $_"
    }
}

# Fonction 2 : Désactiver un compte utilisateur
function Disable-ADUserAccount {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserName  # Nom d'utilisateur (SamAccountName) à désactiver
    )

    try {
        # Désactiver le compte utilisateur
        Disable-ADAccount -Identity $UserName
        Write-Output "Le compte $UserName a été désactivé avec succès."
    }
    catch {
        Write-Error "Erreur lors de la désactivation du compte $UserName : $_"
    }
}

# Fonction specifically, we will use the following parameters to determine the format of the output:

# Fonction 3 : Lister tous les utilisateurs d'une OU
function Get-ADUserList {
    param (
        [Parameter(Mandatory=$true)]
        [string]$OU  # Unité d'organisation à interroger
    )

    try {
        # Récupérer tous les utilisateurs de l'OU spécifiée
        $users = Get-ADUser -Filter * -SearchBase $OU | Select-Object Name, SamAccountName, Enabled

        if ($users) {
            Write-Output "Liste des utilisateurs dans $OU :"
            $users | Format-Table -AutoSize
        }
        else {
            Write-Output "Aucun utilisateur trouvé dans $OU."
        }
    }
    catch {
        Write-Error "Erreur lors de la récupération des utilisateurs : $_"
    }
}

# Exporter les fonctions pour qu'elles soient accessibles
Export-ModuleMember -Function New-ADUserAccount, Disable-ADUserAccount, Get-ADUserList