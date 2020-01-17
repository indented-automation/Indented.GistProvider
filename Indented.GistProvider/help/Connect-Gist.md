---
external help file: Indented.GistProvider-help.xml
Module Name: Indented.GistProvider
online version:
schema: 2.0.0
---

# Connect-Gist

## SYNOPSIS
Provides authentication options for GitHub accounts.

## SYNTAX

### OAuth (Default)
```
Connect-Gist -Username <String> [<CommonParameters>]
```

### Basic
```
Connect-Gist -Credential <PSCredential> [<CommonParameters>]
```

## DESCRIPTION
Provides either OAUTH or Basic authentication options for GitHub accounts.

To use OAUTH see Get-Help about_GistProviderOAuth

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Username
{{ Fill Username Description }}

```yaml
Type: String
Parameter Sets: OAuth
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
{{ Fill Credential Description }}

```yaml
Type: PSCredential
Parameter Sets: Basic
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
