#####################################################################################################
#                           Example of use of the EKARA API                                         #
#####################################################################################################
# Swagger interface : https://api.ekara.ip-label.net                                                #
# To be personalized in the code before use: username / password / TOKEN                            #
# Purpose of the script : Enable scenario                                                           #
#####################################################################################################
# Author : Guy Sacilotto
# Last Update : 04/12/2023

<#
Authentication :  user / password / TOKEN
Method call : adm-api/scenarios  /    
Restitution: Console
#>

Clear-Host

#region VARIABLES
#========================== SETTING THE VARIABLES ===============================
$error.clear()
add-type -assemblyName "Microsoft.VisualBasic"
$global:API = "https://api.ekara.ip-label.net"                                                # Webservice URL
$global:UserName = "xxxxxxxxxxxxx"                                                            # EKARA Account
$global:PlainPassword = "xxxxxxxxxx"                                                          # EKARA Password
$global:Token = "xxxxxxxxxxxxxxxxxx"                                                          # AKARA Token
$global:Result_OK = 0
$global:Result_KO = 0

$global:headers = $null
$global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"       # Create Header
$headers.Add("Accept","application/json")                                                     # Setting Header
$headers.Add("Content-Type","application/json")                                               # Setting Header

# Authentication choice
    # 1 = Without asking for an account and password (you must configure the account and password in this script.)
    # 2 = Request the entry of an account and a password (default)
    $global:Auth = 2
#endregion

#region Functions
function Authentication{
    try{
        Switch($Auth){
            1{
                # Without asking for an account and password
                if(($null -ne $UserName -and $null -ne $PlainPassword) -and ($UserName -ne '' -and $PlainPassword -ne '')){
                    Write-Host "--- Automatic AUTHENTICATION (account) ---------------------------" -BackgroundColor Green
                    $uri = "$API/auth/login"                                                                                        # Webservice Methode
                    $response = Invoke-RestMethod -Uri $uri -Method POST -Verbose -Body @{ email = "$UserName"; password = "$PlainPassword"} # Call WebService method
                    $global:Token = $response.token                                                                                        # Register the TOKEN
                    $global:headers.Add("authorization","Bearer $Token")                                                            # Adding the TOKEN into header
                }Else{
                    Write-Host "--- Account and Password not set ! ---------------------------" -BackgroundColor Red
                    Write-Host "--- To use this connection mode, you must configure the account and password in this script." -ForegroundColor Red
                    exit
                }
            }
            2{
                # Requests the entry of an account and a password (default) 
                Write-Host "------------------------------ AUTHENTICATION with account entry ---------------------------" -ForegroundColor Green
                $MyAccount = $Null
                $MyAccount = Get-credential -Message "EKARA login account" -ErrorAction Stop               # Request entry of the EKARA Account
                if(($null -ne $MyAccount) -and ($MyAccount.password.Length -gt 0)){
                    $UserName = $MyAccount.GetNetworkCredential().username
                    $PlainPassword = $MyAccount.GetNetworkCredential().Password
                    $uri = "$API/auth/login"
                    $response = Invoke-RestMethod -Uri $uri -Method POST -Body @{ email = "$UserName"; password = "$PlainPassword"} # Call WebService method
                    $Token = $response.token                                                               # Register the TOKEN
                    $global:headers.Add("authorization","Bearer $Token")
                }Else{
                    Write-Host "--- Account and password not specified ! ---------------------------" -BackgroundColor Red
                    Write-Host "--- To use this connection mode, you must enter Account and password." -ForegroundColor Red
                    exit
                }
            }

        }
    }Catch{

    Write-Host "-------------------------------------------------------------" -ForegroundColor red 
        Write-Host "Erreur ...." -BackgroundColor Red
        Write-Host $Error.exception.Message[0]
        Write-Host $Error[0]
        Write-host $error[0].ScriptStackTrace
        Write-Host "-------------------------------------------------------------" -ForegroundColor red
        Break
    }
}

function Hide-Console{
    # .Net methods Permet de réduire la console PS dans la barre des tâches
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide / 1 normal / 2 réduit 
    [Console.Window]::ShowWindow($consolePtr, 2)
}

Function List_Scenario_ID{
    try{
        #========================== adm-api/scenarios =============================
        Write-Host "-------------------------------------------------------------" -ForegroundColor green
        Write-Host "------------------- Liste les scenarios désactivé -------------------" -BackgroundColor "White" -ForegroundColor "DarkCyan"
        $uri ="$API/adm-api/scenarios"
        $scenarios = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Verbose 
        $scenarios = $scenarios | Where-Object {$_.active -EQ 0}                                             #List only Disabled scenarios
        $count = $scenarios.count

        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        function ListIndexChanged { 
            $label2.Text = $listbox.SelectedItems.Count
        }

        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'List of deactivated scenarios'
        $form.Size = New-Object System.Drawing.Size(350,400)
        $form.StartPosition = 'CenterScreen'
        $Form.Opacity = 1.0
        $Form.TopMost = $false
        $Form.ShowIcon = $true                                              # Enable icon (upper left corner) $ true, disable icon
        #$Form.FormBorderStyle = 'Fixed3D'                                  # bloc resizing form

        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Point(75,330)
        $okButton.Size = New-Object System.Drawing.Size(75,23)
        $okButton.Text = 'OK'
        $okButton.AutoSize = $true
        $okButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom 
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $okButton

        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Location = New-Object System.Drawing.Point(150,330)
        $cancelButton.Size = New-Object System.Drawing.Size(75,23)
        $cancelButton.Text = 'Cancel'
        $cancelButton.AutoSize = $true
        $cancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom 
        $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.CancelButton = $cancelButton
        
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10,20)
        $label.Size = New-Object System.Drawing.Size(280,20)
        $label.Text = 'Select the scenarios to activate:'
        $label.AutoSize = $true
        $label.Anchor = [System.Windows.Forms.AnchorStyles]::Top `
        -bor [System.Windows.Forms.AnchorStyles]::Bottom `
        -bor [System.Windows.Forms.AnchorStyles]::Left `
        -bor [System.Windows.Forms.AnchorStyles]::Right

        $label2 = New-Object System.Windows.Forms.Label
        $label2.Location = New-Object System.Drawing.Point(10,335)
        $label2.Size = New-Object System.Drawing.Size(20,20)
        $label2.Text = ListIndexChanged
        $label2.AutoSize = $true
        $label2.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom `
        -bor [System.Windows.Forms.AnchorStyles]::Left 

        $listBox = New-Object System.Windows.Forms.ListBox
        $listBox.Location = New-Object System.Drawing.Point(10,40)
        $listBox.Size = New-Object System.Drawing.Size(310,20)
        $listBox.Height = 280
        $listBox.SelectionMode = 'MultiExtended'
        $ListBox.Anchor = [System.Windows.Forms.AnchorStyles]::Top `
        -bor [System.Windows.Forms.AnchorStyles]::Bottom `
        -bor [System.Windows.Forms.AnchorStyles]::Left `
        -bor [System.Windows.Forms.AnchorStyles]::Right

        $listboxCollection =@()

        foreach($scenario in $scenarios){
            $Object = New-Object Object 
            $Object | Add-Member -type NoteProperty -Name id -Value $scenario.id
            $Object | Add-Member -type NoteProperty -Name name -Value $scenario.name
            $listboxCollection += $Object
        }
        
        # Count selected item
        $ListBox.Add_SelectedIndexChanged({ ListIndexChanged })

        #Add collection to the $listbox
        $listBox.Items.AddRange($listboxCollection)
        $listBox.ValueMember = "$listboxCollection.id"
        $listBox.DisplayMember = "$listboxCollection.name"
        
        #Add composant into Form
        $form.Controls.Add($okButton)
        $form.Controls.Add($cancelButton)
        $form.Controls.Add($listBox)
        $form.Controls.Add($label2)
        $form.Controls.Add($label)
        $form.Topmost = $true
        $result = $form.ShowDialog()
        
        if (($result -eq [System.Windows.Forms.DialogResult]::OK) -and $listbox.SelectedItems.Count -gt 0)
        {
            Foreach($item in $listBox.SelectedItems){
                Write-Host "------------------- Scécario(s) sélectionné(s) -------------------" -BackgroundColor "White" -ForegroundColor "DarkCyan"
                $ItemsName = $item.name
                Write-Host "ItemsName sélectionné :$ItemsName" -ForegroundColor Green
                $ItemsID = $item.id
                Write-Host "ItemsID sélectionné :$ItemsID" -ForegroundColor Green
                    
                Desable_senario -ScenatioName $ItemsName -ScenatioID $ItemsID
            }
            Write-Host ("Sénario enabled : " + $Result_OK)
            [System.Windows.Forms.MessageBox]::Show("Sénario enabled : $Result_OK","Resultat",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Information)

        }else{
            Write-Host "Aucun scénario sélectionné" -ForegroundColor Red
            [System.Windows.Forms.MessageBox]::Show(`
                "------------------------------------`n`r Aucun scénario sélectionné`n`r------------------------------------`n`r",`
                "Resultat",[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    }
    catch{
        Write-Host "-------------------------------------------------------------" -ForegroundColor red
        Write-Host "Erreur ...." -BackgroundColor Red
        Write-Host $Error.exception.Message[0]
        Write-Host $Error[0]
        Write-host $error[0].ScriptStackTrace
        Write-Host "-------------------------------------------------------------" -ForegroundColor red
    } 
}

Function Desable_senario($ScenatioName,$ScenatioID){
    try{
        Write-Host "------------------- Activation du nouveau scenario -------------------" -BackgroundColor "White" -ForegroundColor "DarkCyan"
        Write-Host "--> Activation du scénario [$ScenatioName], id [$ScenatioID]" -ForegroundColor "Green"

         $uri ="$API/adm-api/scenario/$ScenatioID/start"
         $requestWS = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -Verbose  
         if ($requestWS.success -eq $true)   {
            Write-Host "Sécénario [$ScenatioName] activé avec sucess"
            Write-Host $requestWS.message
            $global:Result_OK = $global:Result_OK+1
         }else{
            Write-Host "Echec lors de l'activation du scénario [$ScenatioName]"
            $global:Result_KO = $global:Result_KO+1
         }
         return $Result_OK
    }catch{
        Write-Host -message "-------------------------------------------------------------" -ForegroundColor Red
        Write-Host -message "Erreur read_csv_file ...." -BackgroundColor "Red"
        Write-Host -message $Error.exception.Message[0]
        Write-Host -message $Error[0]
        Write-Host -message $error[0].ScriptStackTrace
        Write-Host -message "-------------------------------------------------------------" -ForegroundColor red
        exit
    }  
}

#endregion

#region Main
#========================== START SCRIPT ======================================
Hide-Console
Authentication
List_Scenario_ID
#endregion