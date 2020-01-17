---
external help file: Indented.GistProvider-help.xml
Module Name: Indented.GistProvider
online version:
schema: 2.0.0
---

# Register-GistOAuthSecret

## SYNOPSIS
Registers OAuth secrets for use with the gist provider.

## SYNTAX

```
Register-GistOAuthSecret [-ClientID] <String> [-ClientSecret] <String> [-CallbackUrl] <Uri>
 [<CommonParameters>]
```

## DESCRIPTION
OAuth applications are registered to accounts in GitHub under Developer Settings.

The secrets used by this provider are stored in this modules directory in clear text.
OAuth should
only be used if the risk is acceptible.

When configuring the application, the Authorization Callback URL must be set to http://localhost.
A
port number may be used, for example http://localhost:40000.
The callback URL is stored when the secrets
are registered.
An HTTP listener is created to accept the authorization token from the callback URL.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -ClientID
The ClientID for this GitHub application.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
The ClientSecret for this GitHub application.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallbackUrl
The Callback URL which should be used for this GitHub application.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
