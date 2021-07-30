using Sytem.Management.Automation;

namespace PowerShellCmdlet1
{
  [Cmdlet(VerbsCommon.Get, "PowerShell_PSCmdlet1")]
  public class PowerShell_PSCmdlet1 : PSCmdlet
  {
    protected override void ProcessRecord()
    {
      base.ProcessRecord();
      WriteObject("Hello World...!");
    }
  }
}
