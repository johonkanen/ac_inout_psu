#ifndef SERIAL_INIT
#define SERIAL_INIT

void  pollport(void *arg);   // function prototype
void* init_serial(void);
void  writeport(void *arg);

struct semaphore
{
	short unsigned int acknowledge;
	short unsigned int writeok;
	short unsigned int data_ready;
	short unsigned int recievemsg;
	short unsigned int quit;
};


#define m_2pow15 0x7fff
#define m_2pow14 0x3fff
#define m_2pow13 0x1fff
#define m_2pow12 0xfff
#define m_2pow11 0x7ff
#define m_2pow10  0x3ff
#define m_2pow9  0x1ff
#define m_2pow8  0xff



#endif
