<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Partial Class LoginForm
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()>
    Protected Overrides Sub Dispose(disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()>
    Private Sub InitializeComponent()
        Me.LabelTitle = New System.Windows.Forms.Label()
        Me.LabelUsername = New System.Windows.Forms.Label()
        Me.LabelPassword = New System.Windows.Forms.Label()
        Me.TextBoxUsername = New System.Windows.Forms.TextBox()
        Me.TextBoxPassword = New System.Windows.Forms.TextBox()
        Me.ButtonLogin = New System.Windows.Forms.Button()
        Me.ButtonCancel = New System.Windows.Forms.Button()
        Me.LabelError = New System.Windows.Forms.Label()
        Me.PanelMain = New System.Windows.Forms.Panel()
        Me.LabelSubtitle = New System.Windows.Forms.Label()
        Me.PanelMain.SuspendLayout()
        Me.SuspendLayout()
        '
        'LabelTitle
        '
        Me.LabelTitle.AutoSize = True
        Me.LabelTitle.Font = New System.Drawing.Font("Segoe UI", 18.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point)
        Me.LabelTitle.ForeColor = System.Drawing.Color.FromArgb(CType(CType(25, Byte), Integer), CType(CType(118, Byte), Integer), CType(CType(210, Byte), Integer))
        Me.LabelTitle.Location = New System.Drawing.Point(130, 30)
        Me.LabelTitle.Name = "LabelTitle"
        Me.LabelTitle.Size = New System.Drawing.Size(78, 32)
        Me.LabelTitle.TabIndex = 0
        Me.LabelTitle.Text = "EvAlis"
        '
        'LabelSubtitle
        '
        Me.LabelSubtitle.AutoSize = True
        Me.LabelSubtitle.Font = New System.Drawing.Font("Segoe UI", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point)
        Me.LabelSubtitle.ForeColor = System.Drawing.Color.Gray
        Me.LabelSubtitle.Location = New System.Drawing.Point(95, 62)
        Me.LabelSubtitle.Name = "LabelSubtitle"
        Me.LabelSubtitle.Size = New System.Drawing.Size(152, 15)
        Me.LabelSubtitle.TabIndex = 1
        Me.LabelSubtitle.Text = "Educational Evaluation Platform"
        '
        'LabelUsername
        '
        Me.LabelUsername.AutoSize = True
        Me.LabelUsername.Font = New System.Drawing.Font("Segoe UI", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point)
        Me.LabelUsername.Location = New System.Drawing.Point(40, 100)
        Me.LabelUsername.Name = "LabelUsername"
        Me.LabelUsername.Size = New System.Drawing.Size(68, 17)
        Me.LabelUsername.TabIndex = 2
        Me.LabelUsername.Text = "Username:"
        '
        'TextBoxUsername
        '
        Me.TextBoxUsername.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point)
        Me.TextBoxUsername.Location = New System.Drawing.Point(40, 120)
        Me.TextBoxUsername.Name = "TextBoxUsername"
        Me.TextBoxUsername.Size = New System.Drawing.Size(260, 25)
        Me.TextBoxUsername.TabIndex = 0
        '
        'LabelPassword
        '
        Me.LabelPassword.AutoSize = True
        Me.LabelPassword.Font = New System.Drawing.Font("Segoe UI", 9.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point)
        Me.LabelPassword.Location = New System.Drawing.Point(40, 160)
        Me.LabelPassword.Name = "LabelPassword"
        Me.LabelPassword.Size = New System.Drawing.Size(64, 17)
        Me.LabelPassword.TabIndex = 4
        Me.LabelPassword.Text = "Password:"
        '
        'TextBoxPassword
        '
        Me.TextBoxPassword.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point)
        Me.TextBoxPassword.Location = New System.Drawing.Point(40, 180)
        Me.TextBoxPassword.Name = "TextBoxPassword"
        Me.TextBoxPassword.PasswordChar = Global.Microsoft.VisualBasic.ChrW(42)
        Me.TextBoxPassword.Size = New System.Drawing.Size(260, 25)
        Me.TextBoxPassword.TabIndex = 1
        '
        'ButtonLogin
        '
        Me.ButtonLogin.BackColor = System.Drawing.Color.FromArgb(CType(CType(25, Byte), Integer), CType(CType(118, Byte), Integer), CType(CType(210, Byte), Integer))
        Me.ButtonLogin.Cursor = System.Windows.Forms.Cursors.Hand
        Me.ButtonLogin.FlatAppearance.BorderSize = 0
        Me.ButtonLogin.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.ButtonLogin.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point)
        Me.ButtonLogin.ForeColor = System.Drawing.Color.White
        Me.ButtonLogin.Location = New System.Drawing.Point(40, 230)
        Me.ButtonLogin.Name = "ButtonLogin"
        Me.ButtonLogin.Size = New System.Drawing.Size(125, 35)
        Me.ButtonLogin.TabIndex = 2
        Me.ButtonLogin.Text = "Login"
        Me.ButtonLogin.UseVisualStyleBackColor = False
        '
        'ButtonCancel
        '
        Me.ButtonCancel.BackColor = System.Drawing.Color.FromArgb(CType(CType(224, Byte), Integer), CType(CType(224, Byte), Integer), CType(CType(224, Byte), Integer))
        Me.ButtonCancel.Cursor = System.Windows.Forms.Cursors.Hand
        Me.ButtonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.ButtonCancel.FlatAppearance.BorderSize = 0
        Me.ButtonCancel.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.ButtonCancel.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point)
        Me.ButtonCancel.ForeColor = System.Drawing.Color.Black
        Me.ButtonCancel.Location = New System.Drawing.Point(175, 230)
        Me.ButtonCancel.Name = "ButtonCancel"
        Me.ButtonCancel.Size = New System.Drawing.Size(125, 35)
        Me.ButtonCancel.TabIndex = 3
        Me.ButtonCancel.Text = "Cancel"
        Me.ButtonCancel.UseVisualStyleBackColor = False
        '
        'LabelError
        '
        Me.LabelError.AutoSize = True
        Me.LabelError.Font = New System.Drawing.Font("Segoe UI", 9.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point)
        Me.LabelError.ForeColor = System.Drawing.Color.Red
        Me.LabelError.Location = New System.Drawing.Point(40, 275)
        Me.LabelError.MaximumSize = New System.Drawing.Size(260, 0)
        Me.LabelError.Name = "LabelError"
        Me.LabelError.Size = New System.Drawing.Size(0, 15)
        Me.LabelError.TabIndex = 8
        Me.LabelError.Visible = False
        '
        'PanelMain
        '
        Me.PanelMain.BackColor = System.Drawing.Color.White
        Me.PanelMain.Controls.Add(Me.LabelTitle)
        Me.PanelMain.Controls.Add(Me.LabelSubtitle)
        Me.PanelMain.Controls.Add(Me.LabelUsername)
        Me.PanelMain.Controls.Add(Me.TextBoxUsername)
        Me.PanelMain.Controls.Add(Me.LabelPassword)
        Me.PanelMain.Controls.Add(Me.TextBoxPassword)
        Me.PanelMain.Controls.Add(Me.ButtonLogin)
        Me.PanelMain.Controls.Add(Me.ButtonCancel)
        Me.PanelMain.Controls.Add(Me.LabelError)
        Me.PanelMain.Dock = System.Windows.Forms.DockStyle.Fill
        Me.PanelMain.Location = New System.Drawing.Point(0, 0)
        Me.PanelMain.Name = "PanelMain"
        Me.PanelMain.Size = New System.Drawing.Size(340, 310)
        Me.PanelMain.TabIndex = 9
        '
        'LoginForm
        '
        Me.AcceptButton = Me.ButtonLogin
        Me.AutoScaleDimensions = New System.Drawing.SizeF(7.0!, 15.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.CancelButton = Me.ButtonCancel
        Me.ClientSize = New System.Drawing.Size(340, 310)
        Me.Controls.Add(Me.PanelMain)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "LoginForm"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "EvAlis - Login"
        Me.PanelMain.ResumeLayout(False)
        Me.PanelMain.PerformLayout()
        Me.ResumeLayout(False)
    End Sub

    Friend WithEvents LabelTitle As System.Windows.Forms.Label
    Friend WithEvents LabelSubtitle As System.Windows.Forms.Label
    Friend WithEvents LabelUsername As System.Windows.Forms.Label
    Friend WithEvents TextBoxUsername As System.Windows.Forms.TextBox
    Friend WithEvents LabelPassword As System.Windows.Forms.Label
    Friend WithEvents TextBoxPassword As System.Windows.Forms.TextBox
    Friend WithEvents ButtonLogin As System.Windows.Forms.Button
    Friend WithEvents ButtonCancel As System.Windows.Forms.Button
    Friend WithEvents LabelError As System.Windows.Forms.Label
    Friend WithEvents PanelMain As System.Windows.Forms.Panel

End Class
