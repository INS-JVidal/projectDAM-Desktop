Imports System.ComponentModel
Imports System.Windows.Forms

''' <summary>
''' Splash screen form displayed during application startup.
''' Shows status messages while Docker and database are being initialized.
''' </summary>
Public Class SplashScreenForm
    Inherits Form

    Private _title As String
    Private _message As String

    ''' <summary>
    ''' Initializes a new instance of the SplashScreenForm with title and message.
    ''' </summary>
    Public Sub New(title As String, message As String)
        _title = title
        _message = message
        Me.StartPosition = FormStartPosition.CenterScreen
        Me.TopMost = True
        Me.ControlBox = False
        Me.FormBorderStyle = FormBorderStyle.None
    End Sub

    ''' <summary>
    ''' Handles the form load event.
    ''' </summary>
    Private Sub SplashScreenForm_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        Me.Width = 400
        Me.Height = 200
        Me.BackColor = Color.FromArgb(245, 245, 245)

        ' Create title label
        Dim labelTitle As New Label()
        labelTitle.Text = _title
        labelTitle.Font = New Font("Segoe UI", 14, FontStyle.Bold)
        labelTitle.ForeColor = Color.FromArgb(51, 51, 51)
        labelTitle.Left = 20
        labelTitle.Top = 30
        labelTitle.Width = Me.Width - 40
        labelTitle.Height = 30
        Me.Controls.Add(labelTitle)

        ' Create message label
        Dim labelMessage As New Label()
        labelMessage.Text = _message
        labelMessage.Font = New Font("Segoe UI", 10)
        labelMessage.ForeColor = Color.FromArgb(102, 102, 102)
        labelMessage.Left = 20
        labelMessage.Top = 70
        labelMessage.Width = Me.Width - 40
        labelMessage.Height = 40
        labelMessage.AutoSize = False
        Me.Controls.Add(labelMessage)

        ' Create progress bar
        Dim progressBar As New ProgressBar()
        progressBar.Style = ProgressBarStyle.Marquee
        progressBar.Left = 20
        progressBar.Top = 130
        progressBar.Width = Me.Width - 40
        progressBar.Height = 20
        Me.Controls.Add(progressBar)
    End Sub

    ''' <summary>
    ''' Prevents the form from being closed with Alt+F4.
    ''' </summary>
    Protected Overrides Sub OnFormClosing(e As FormClosingEventArgs)
        If e.CloseReason = CloseReason.UserClosing Then
            e.Cancel = True
        End If
        MyBase.OnFormClosing(e)
    End Sub

End Class
