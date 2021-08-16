#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <stdio.h>
#include <process.h>         // needed for _beginthread()
//#include <curses.h>
#include "serial_init.h"
#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

#define NOTFOUND 0xffffffff

int main(void)
{	
	HANDLE hSerial;
	HANDLE receiverThread = NULL;
	void* writeportargs[2];
	semaphore read_port;
	
	hSerial = (HANDLE)init_serial();
	
	char szBuff[100] = {0};
	short unsigned int senddata;
	float duty;
	float duty1 = 0;
	float duty2 = 0;

	float vkp = 0;
	float vki = 0;

	float ikp = 0;
	float iki = 0;

	int dontquit = 0;

	char merkki = 0;
	int i = 0;
	DWORD dwBytesRead = 0;
	DWORD dwBytesWrite = 0;

	using std::string;
	using std::cout;
	using std::endl;

	string streambuf;

	//init semaphore between threads

	read_port.readok = 0;
	read_port.writeok = 0;
	read_port.sendmsg = 0;
	read_port.recievemsg = 0;
	read_port.quit = 0;

	writeportargs[0] = (void*)hSerial;
	writeportargs[1] = &read_port;

	read_port.readok = 16358;

	//start read thread
    //_beginthread( pollport, 0, (void*)writeportargs );

	//start write thread
	//_beginthread( writeport, 0, (void*)writeportargs );
	while(i!=7)
	{
		dontquit = 0;
		std::cout<< ("press 'q' to quit: ") <<endl <<">";
		std::getline(std::cin, streambuf);

		string temp = streambuf;

		string command = temp.substr(0, temp.find(" "));

		temp = temp.substr(temp.find(" ") + 1);//extract first parameter
		string cmdline_number = temp.substr(0, temp.find(" "));//save to string cmdline_number

		std::stringstream myStream(cmdline_number);

		if (streambuf.find("vref") == NOTFOUND)
		{

			if (myStream >> duty)
			{
				if (duty <= 65535 && duty >= 0)
				{
					//do nothing
				}
				else
				{
					duty = -10;//invalid value
				}
			}
		}

		if (streambuf.find('q') == 0) // check if 'q' is the first character in stream
			{
				i = 7;
				dontquit = 1; // stop modulation when exiting
			}
		if (streambuf.find("duty1") != NOTFOUND)//.find returns 0xffffffff, if not found
			{
				if (duty <= 1 && duty >= 0)
				{
					duty = floor(4095 * duty);
					senddata = (unsigned short int)duty;
					szBuff[0] = senddata >> 8;
					szBuff[1] = senddata;
					WriteFile(hSerial, szBuff, 2, &dwBytesRead, NULL);
					duty1 = duty / 4095;
					cout << endl << "duty1: " << duty1 << endl << "duty2: " << duty2 << endl << endl;
				}
				else
				{
					cout << "invalid pri duty ratio" << endl;
				}
			}
		else if (streambuf.find("raw") != NOTFOUND)
		{
			//set mailbox* pri current lp
			senddata =(unsigned short int)duty;
			szBuff[0] = senddata >> 8;
			szBuff[1] = senddata;
			WriteFile(hSerial, szBuff, 2, &dwBytesRead, NULL);
			cout << endl << "logging secondary voltage!" << endl << endl;
		}

		else if (streambuf.find("duty") != NOTFOUND)
		{
			//set mailbox* pri current lp
			cout << endl << "duty1: " << duty1 <<endl << "duty2: "<< duty2 << endl << endl;
		}
		else if (streambuf.find("exit") != NOTFOUND)
		{
			//set mailbox* pri current lp
			cout << endl << "Quit without turning off converter!! " << duty2 << endl << endl;
			i = 7;
		}


		else if (streambuf.find("log") != NOTFOUND)
			{
				_beginthread(pollport, 0, (void*)writeportargs);
			}

		else
			{
				if (i!=7)
					std::cout << "Invalid selection" << std::endl << std::endl; 
			}

		duty = -10;
	}
	read_port.quit = 1;
	while (read_port.writeok == 1);

	//stop modulation
	if (dontquit != 0)
	{

		senddata = 0xf999;
		szBuff[0] = senddata >> 8;
		szBuff[1] = senddata;
		WriteFile(hSerial, szBuff, 2, &dwBytesRead, NULL);
		cout << endl << "Stop modulation!" << endl << endl;
	}
	//printf("\ntest is %d",testi);
	//refresh();
    PurgeComm(hSerial,PURGE_RXCLEAR); //clear the filebuffer
	CloseHandle(hSerial);

	return 0;
}
