#define _CRT_SECURE_NO_WARNINGS
#include "serial_init.h"
#include <stdio.h>
#include <windows.h>

#define bufferlength (1e5 * 3)

void  pollport(void *args) // threaded function to poll serial port
{

	void** readargs;
	readargs = (void**)args;

	semaphore* read_port;
	HANDLE hSerial;

	read_port = (semaphore*)*(readargs+1);
	hSerial = (void*)*(readargs);

	FILE *fptr/*, *fptr2*/;
	fptr = fopen("ad_test.txt", "w");
	//	fptr2=fopen("ad_test2.txt","w");

	unsigned int BUFFER_SIZE = 2;
	long int i = 0;
	int j = 0;
	DWORD dwBytesRead = 0;
	DWORD dwBytesWrite = 0;
	BOOL	redfail = false;
	BOOL	purgefail = false;
	DWORD	lasterror = 0;
	DWORD eventMask = EV_RXCHAR;
	BOOL retVal = FALSE;


	unsigned char szBuff[2] = { 0 };
	unsigned int merkki		= 0;
	int* data;
	int* data2;
	int cnt0 = 0, cnt1 = 0, cnt2 = 0;
	int cnt1ind = 0;

	data = (int*)malloc(sizeof(int)*bufferlength);
	data2 = (int*)malloc(sizeof(int)*bufferlength);

	int dly = 0;

	printf("\Data collection started\n");

	while (i < bufferlength && read_port->quit == 0) 
	{
		memset(szBuff, 0, BUFFER_SIZE);
		/// Waits for an event to occur for the port.
		retVal = WaitCommEvent(hSerial, &eventMask, NULL);
		if ((eventMask & EV_RXCHAR) == EV_RXCHAR)
		{
			dwBytesRead = 0;
				redfail = ReadFile(hSerial, szBuff, 2, &dwBytesRead, NULL);
			switch (dwBytesRead)
			{
			case 0:
				cnt0++;
				break;
			case 1:
				cnt1++;
				cnt1ind = i;
				break;
			case 2:
				cnt2++;
				break;
			default:
				break;
			}


			data[i] = (((short int)szBuff[0]) << 8) & (short int)0xFF00;
			data[i] |= ((short int)szBuff[1]) & (short int)0x00FF;
			
			data2[i] = (short int)merkki;
			data2[i] |=((short int)szBuff[0]) & (short int)0x00FF;
			merkki =  (((short int)szBuff[1]) << 8) & (short int)0xFF00;
			i++;
		}
	}

	for (i = 0; i < bufferlength;i++)
	{
		fprintf(fptr, "%d\t%d\n", (unsigned short int)data[i], (unsigned short int)data2[i]);
	}

	printf("\nFile saved\n");
	printf("cnt0: %d\n", cnt0);
	printf("cnt1: %d\n", cnt1);
	printf("cnt2: %d\n", cnt2);
	printf("cnt1ind: %d\n", cnt1ind+1);
	PurgeComm(hSerial,PURGE_RXCLEAR); //clear the filebuffer
	free(data);
	free(data2);
	fclose(fptr);

    

//	fclose(fptr2);
}


void  writeport(void *args) // threaded function to write to serial port
{
	void** readargs;
	readargs = (void**)args;

	semaphore* read_port;
	HANDLE hSerial;

	read_port = (semaphore*)*(readargs+1);
	hSerial = (void*)*(readargs);

	DWORD dwBytesWrite = 0;

	short unsigned int szBuff[2];

	szBuff[0] = 159;
	szBuff[1] = 37;

	WriteFile(hSerial, szBuff, 2, &dwBytesWrite, NULL);

	read_port->writeok = 1;

	while(read_port->quit == 0);

	printf("\n\nJee, I is in another thread! Readok == %i,\n\n",read_port->readok);
	WriteFile(hSerial, szBuff, 2, &dwBytesWrite, NULL);

	read_port->writeok = 0;

};
HANDLE init_serial(void)
{
	HANDLE hSerial;
	hSerial = CreateFile(	"\\\\.\\COM4",//COM5
							GENERIC_READ | GENERIC_WRITE,
							0,
							0,
							OPEN_EXISTING,
							FILE_ATTRIBUTE_NORMAL,
							0);
	if(hSerial==INVALID_HANDLE_VALUE)
	{
		if(GetLastError()==ERROR_FILE_NOT_FOUND)
		{
			printf("does not compute\n");
		}
			//some other error occurred. Inform user.
		printf("does not compute either :(\n");
	}

	DCB dcbSerialParams = {0};

	dcbSerialParams.DCBlength=sizeof(dcbSerialParams); // strange quirk of windows

	if (!GetCommState(hSerial, &dcbSerialParams)) 
	{
	//error getting state
	}
	
	dcbSerialParams.BaudRate=5e6; //937500
 	dcbSerialParams.ByteSize=8;
	dcbSerialParams.StopBits=ONESTOPBIT;
	dcbSerialParams.Parity=NOPARITY;
	
	if(!SetCommState(hSerial, &dcbSerialParams))
	{
	//error setting serial port state
	}

	COMMTIMEOUTS timeouts={0};
	timeouts.ReadIntervalTimeout=100;
	timeouts.ReadTotalTimeoutConstant = 0;
	timeouts.ReadTotalTimeoutMultiplier=0;

	timeouts.WriteTotalTimeoutConstant=0;
	timeouts.WriteTotalTimeoutMultiplier =0;
	
	if(!SetCommTimeouts(hSerial, &timeouts))
	{
		//error occureed. Inform user
	}
	return (void*)hSerial;
}
