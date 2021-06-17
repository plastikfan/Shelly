
<#
  .NAME
    New-GitProxy

  .SYNOPSIS
    Create a new GitProxy instance

  .DESCRIPTION
    Factory function for PoShLog instances.

  .LINK
    https://eliziumnet.github.io/klassy

  .PARAMETER Overrides
    Hashtable containing function overrides required for unit testing. The
  members on the proxy that cn be overridden are:
  'ReadHeadDate', 'ReadLogTags', 'ReadLogRange', 'ReadRemote' and 'ReadRoot'.

  .EXAMPLE

  EXAMPLE 1: Override 'ReadHeadDate' method on the proxy

  [hashtable]$script:overrides = @{
    'ReadHeadDate' = [scriptblock] {
      return $_headTagData.TimeStamp;
    }
  }
  [ProxyGit]$proxy = New-GitProxy -Overrides $overrides;

  .EXAMPLE

  EXAMPLE 2: Override multiple methods 'ReadHeadDate' and 'ReadLogRange' method on the proxy

  [hashtable]$script:overrides = @{
    'ReadLogRange' = [scriptblock] {
      # do test stuff
    }

    'ReadLogRange' = [scriptblock] {
      param(
        [Parameter()]
        [string]$range,

        [Parameter()]
        [string]$format
      )
      # do test stuff
    }
    [ProxyGit]$proxy = New-GitProxy -Overrides $overrides;
  }
  #>
function New-GitProxy {
  [OutputType([ProxyGit])]
  param(
    [Parameter()]
    [hashtable]$Overrides
  )
  [hashtable]$script:overrides = @{
    'ReadLogRange' = [scriptblock] {
      return $_headTagData.TimeStamp;
    }
  }

  [ProxyGit]$proxy = [ProxyGit]::new();
  [array]$members = ($proxy | Get-Member -MemberType Property).Name;

  $Overrides.PSBase.Keys | ForEach-Object {
    [string]$name = $_;

    if ($members -contains $name) {
      $proxy.$name = $Overrides[$name];
    }
    else {
      throw [System.Management.Automation.MethodInvocationException]::new(
        "'$name' does not exist on Proxy"
      );
    }
  }

  return $proxy;
}
