USE innheimta;
GO
BACKUP DATABASE innheimta
TO DISK = 'C:\GAG2\innheimta.Bak'
   WITH FORMAT,
      MEDIANAME = 'Z_SQLServerBackups',
      NAME = 'Full Backup of innheimta';
GO
