#************************************
# Author: Kevin RAHETILAHY
# e-mail: kevin_rhtl@hotmail.com
# review-date : 16/05/2016
#************************************

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

$Global:my_application_path= split-path -parent $MyInvocation.MyCommand.Definition

$XamlMainWindow=LoadXaml($my_application_path+"\Form.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)

#########################################################################
#                        Load external scripts                          #
#########################################################################
."$my_application_path\common.ps1"                                      #
#########################################################################


$BrowseButton        = $Form.FindName("BrowseFile")
$FileLocationTExtBox = $Form.FindName("FileLocation")
$ButtonParse         = $Form.FindName("ParseFile")
$TextBlocContent     = $Form.FindName("TextBlocForContent")
$listView            = $Form.FindName("listView")
$FileIniLocation     = ""

#########################################################################
#                         Event Manager                                 #
#########################################################################

$BrowseButton.Add_Click({	
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filter = "Ini Files (*.ini)| *.ini" # Set the file types 
    $OpenFileDialog.initialDirectory = [Environment]::GetFolderPath("Desktop")
    $OpenFileDialog.ShowDialog() | Out-Null
    $Script:FileIniLocation = $OpenFileDialog.filename
	$FileLocationTExtBox.Text = $OpenFileDialog.filename
})

$ButtonParse.Add_Click({

    

    if($FileIniLocation -ne ""){
        try {
           
           if($listView.Items.Count -ne 0){ $listView.Items.Clear()}
           $Global:IniFileContentStruct = parseIniFile -Inputfile $FileIniLocation
           

           #$IniFileContentData = $IniFileContentStruct.Content                           # For PS v4
           $IniFileContentData = $IniFileContentStruct | Select-Object -Property Content  # For PS v2
           $index = 0;
            
           Foreach($Section in $IniFileContentData ){

                $CurrentSection = $IniFileContentStruct[$index].Section
                $index++        
                #$Global:CustomArray = $Section.GetEnumerator()| % {  "{0}; {1}; {2}" -f $CurrentSection, $_.key, $_.value }  # For PS v4
                $Global:CustomArray = $Section.Content.GetEnumerator()| % {  "{0} ; {1} ; {2}" -f $CurrentSection, $_.key, $_.value }  # For PS v2
              
                $ContentObject = @()                 
                    
                Foreach($line in $CustomArray) {
                    if($line -eq $Null){
                        $objArray = New-Object PSObject
                        $objArray | Add-Member -type NoteProperty -name section -value $CurrentSection
                        $objArray | Add-Member -type NoteProperty -name parameter -value " " 
                        $objArray | Add-Member -type NoteProperty -name value -value " "
                        $ContentObject += $objArray
                    }
                    else {
                        $currentline = $line.split(";")
                        $objArray = New-Object PSObject
                        $objArray | Add-Member -type NoteProperty -name section -value $currentline[0]
                        $objArray | Add-Member -type NoteProperty -name parameter -value $currentline[1] 
                        $objArray | Add-Member -type NoteProperty -name value -value $currentline[2]
                        $ContentObject += $objArray
                    }
                    $listView.Items.Add($objArray)
                
                }          
               
            
           } 
           $TextBlocContent.Foreground = "Green"
           $TextBlocContent.Text = "Parsing completed succesfully."
           
        }
        catch {
                $ErrorMessage = $_.Exception.Message
                $TextBlocContent.Foreground = "Red"
                $TextBlocContent.Text = $ErrorMessage
        }
    }
    else{
        $TextBlocContent.Foreground = "Orange"
        $TextBlocContent.Text = "no file to parse."
    }
})

$Form.add_MouseLeftButtonDown({
   $_.handled=$true
   $this.DragMove()
})
     

#########################################################################
#                        Show Dialog                                    #
#########################################################################
$Form.ShowDialog() | Out-Null
  