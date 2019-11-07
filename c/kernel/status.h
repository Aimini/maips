#ifndef __STATUS__
#define __STATUS__
class status {
    public:
    typedef int bit_t;
        status(int value) {
            for(int i = 0; i < 4; ++i)
                this->cu[i] = extract_bit(value, 28 + i);
            this->bev = extract_bit(value, 22);
            for(int i = 0; i < 8; ++i)
                this->im[i] = extract_bit(value, 8 + i);
            this->um = extract_bit(value,4);
            this->erl = extract_bit(value,2);
            this->exl = extract_bit(value,1);
            this->ie  = extract_bit(value,0);
        };
        bit_t extract_bit(int value,int offset){
             return (value >> (offset)) & 0x1;
        }

    bit_t cu[4],bev,im[8],um,erl,exl,ie;
};

#endif