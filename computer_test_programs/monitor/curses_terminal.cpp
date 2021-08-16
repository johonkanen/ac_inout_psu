#include <Windows.h>
#include <stdio.h>
#include <process.h>         // needed for _beginthread()

#define NCURSES_MOUSE_VERSION
#include <curses.h>
#include "serial_comm\serial_init.h"
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
	

	short unsigned int senddata;

	using std::string;
	using std::cout;
	using std::endl;

	string streambuf;

	//init semaphore between threads

	read_port.acknowledge = 0;
	read_port.writeok = 0;
	read_port.data_ready = 0;
	read_port.recievemsg = 0;
	read_port.quit = 0;

	writeportargs[0] = (void*)hSerial;
	writeportargs[1] = &read_port;

	//start read thread
    //_beginthread( pollport, 0, (void*)writeportargs );

	//start write thread
	//_beginthread( writeport, 0, (void*)writeportargs );
	MEVENT event;

  int ch = 0;
	initscr();
	raw();
	keypad(stdscr, TRUE);
	noecho();
	mmask_t old;
	mousemask (ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, &old);


	while(ch != 27)
	{
        if (read_port.writeok == 1)
        {
            printw("start logging data\n");
            refresh();
        }

		// ch = getch();
		// if(ch == KEY_MOUSE) {
		// 	if(getmouse(&event) == OK)
		// 	{
		// 		if(event.bstate & BUTTON1_DOUBLE_CLICKED) {
		// 			printw("Double click , x: %d y: %d", event.x, event.y);
        //             _beginthread(pollport, 0, (void*)writeportargs);
		// 			refresh();
		// 		}
		// 	}
		// }
	}
	
	refresh();
	endwin();
    
	// while(i!=7)
	// {
	// 	dontquit = 0;
	// 	std::cout<< ("press 'q' to quit: ") <<endl <<">";
	// 	std::getline(std::cin, streambuf);
    //
	// 	string temp = streambuf;
    //
	// 	string command = temp.substr(0, temp.find(" "));
    //
	// 	temp = temp.substr(temp.find(" ") + 1);//extract first parameter
	// 	string cmdline_number = temp.substr(0, temp.find(" "));//save to string cmdline_number
    //
	// 	std::stringstream myStream(cmdline_number);
    //
	// 	if (streambuf.find("vref") == NOTFOUND)
	// 	{
    //
	// 		if (myStream >> duty)
	// 		{
	// 			if (duty <= 65535 && duty >= 0)
	// 			{
	// 				//do nothing
	// 			}
	// 			else
	// 			{
	// 				duty = -10;//invalid value
	// 			}
	// 		}
	// 	}
    //
	// 	if (streambuf.find('q') == 0) // check if 'q' is the first character in stream
	// 		{
	// 			i = 7;
	// 			dontquit = 1; // stop modulation when exiting
	// 		}
    //
	// 	else if (streambuf.find("raw") != NOTFOUND)
	// 	{
	// 		//set mailbox* pri current lp
	// 		senddata =(unsigned short int)duty;
	// 		szBuff[0] = senddata >> 8;
	// 		szBuff[1] = senddata;
	// 		WriteFile(hSerial, szBuff, 2, &dwBytesRead, NULL);
	// 		cout << endl << "logging secondary voltage!" << endl << endl;
	// 	}
    //
	// 	else if (streambuf.find("exit") != NOTFOUND)
	// 	{
	// 		//set mailbox* pri current lp
	// 		cout << endl << "Quit without turning off converter!! " << duty2 << endl << endl;
	// 		i = 7;
	// 	}
    //
    //
	// 	else if (streambuf.find("log") != NOTFOUND)
	// 		{
	// 			_beginthread(pollport, 0, (void*)writeportargs);
	// 		}
    //
	// 	else
	// 		{
	// 			if (i!=7)
	// 				std::cout << "Invalid selection" << std::endl << std::endl; 
	// 		}
    //
	// 	duty = -10;
	// }
	// read_port.quit = 1;
	// while (read_port.writeok == 1);
    //
	// //stop modulation
	// if (dontquit != 0)
	// {
    //
	// 	senddata = 0xf999;
	// 	szBuff[0] = senddata >> 8;
	// 	szBuff[1] = senddata;
	// 	WriteFile(hSerial, szBuff, 2, &dwBytesRead, NULL);
	// 	cout << endl << "Stop modulation!" << endl << endl;
	// }
	// //printf("\ntest is %d",testi);
	// //refresh();
    PurgeComm(hSerial,PURGE_RXCLEAR); //clear the filebuffer
	CloseHandle(hSerial);

	return 0;
}
