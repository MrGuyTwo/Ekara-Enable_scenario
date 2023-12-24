# Ekara-Enable_scenario

![Windows](screenshot/badge.svg)

<a href="https://api.ekara.ip-label.net/"><img src="screenshot/cropped-ekara_by_ip-label_full_2.webp"> 

## Description
This [Powershell](https://learn.microsoft.com/powershell/scripting/overview) script allows you to activate several [Ekara](https://ekara.ip-label.net/) scenarios.

For this, the script uses the Rest Ekara API.

## Screens

![screen](screenshot/Logon.png)

![screen](screenshot/List_scenarios.png)

![screen](screenshot/Confirm.png)

## Requirements

-|version
--|:--:
Ekara plateform|>=23.12
PowerShell|>=5
.NET|>=4
Microsoft Excel|>=2013

(Account and password Ekara)

## Download

[github-download]: https://github.com/MrGuyTwo/Ekara-Enable_scenario/releases
 - [`Ekara-Enable_scenario`][github-download]

## The main function
Methods called : 

- auth/login
- adm-api/scenarios
- adm-api/scenario/{ScenatioID}/start
