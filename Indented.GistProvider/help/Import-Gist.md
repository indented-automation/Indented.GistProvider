---
external help file: Indented.GistProvider-help.xml
Module Name: Indented.GistProvider
online version:
schema: 2.0.0
---

# Import-Gist

## SYNOPSIS
Import content from gists into PowerShell.

## SYNTAX

```
Import-Gist [[-Gist] <GistFile>] [-AsModule] [-AllowClobber] [<CommonParameters>]
```

## DESCRIPTION
Import-Gist attempts to import content into the current PowerShell session.

By default, Import-Gist searches for and imports functions within a gist.
Import-Gist can also
create a dynamic module from a gist.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Gist
{{ Fill Gist Description }}

```yaml
Type: GistFile
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AsModule
{{ Fill AsModule Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowClobber
{{ Fill AllowClobber Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS