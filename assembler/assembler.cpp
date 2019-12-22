#include<bits/stdc++.h>
using namespace std;
int address,var_address,idx;
unordered_map<string,string>modes,oneOperand,twoOperand,branch,others;
unordered_map<string,int>labels;
unordered_map<string,pair<int,int>>vars;    //first for address,second for value
vector<string>vars_to_memory;
vector<pair<int,pair<vector<string>,int>>>commands;
void lower(string&s)
{
    for(int i=0;i<s.length();i++)   s[i]=tolower(s[i]);
}
string to_binary(int num,int length)
{
    bool neg=(num<0);
    if(neg)
    {
        num++;
        num=abs(num);
    }
    string ret="";
    while(num)  ret+=to_string(num%2),num/=2;
    while(ret.length()<length)  ret+="0";
    reverse(ret.begin(),ret.end());
    if(neg)
    {
        for(int i=0;i<ret.length();i++) ret[i]=(!(ret[i]-'0')+'0');
    }
    return ret;
}
void preProcess()
{
    for(int i=0;i<8;i++)
    {
        modes["R"+to_string(i)]=to_binary(0,3)+to_binary(i,3);          //reg. direct
        modes["@R"+to_string(i)]=to_binary(1,3)+to_binary(i,3);         //reg. indirect
        modes["(R"+to_string(i)+")+"]=to_binary(2,3)+to_binary(i,3);    //auto inc. direct
        modes["@(R"+to_string(i)+")+"]=to_binary(3,3)+to_binary(i,3);   //auto inc. indirect
        modes["-(R"+to_string(i)+")"]=to_binary(4,3)+to_binary(i,3);    //auto dec. direct
        modes["@-(R"+to_string(i)+")"]=to_binary(5,3)+to_binary(i,3);   //auto dec. indirect
        modes["X(R"+to_string(i)+")"]=to_binary(6,3)+to_binary(i,3);    //indexed direct
        modes["@X(R"+to_string(i)+")"]=to_binary(7,3)+to_binary(i,3);   //indexed indirect
    }
    oneOperand["inc"]="1010"+to_binary(16,5)+"0";
    oneOperand["dec"]="1010"+to_binary(17,5)+"0";
    oneOperand["clr"]="1010"+to_binary(31,5)+"0";
    oneOperand["inv"]="1010"+to_binary(8,5)+"0";
    oneOperand["lsr"]="1010"+to_binary(9,5)+"0";
    oneOperand["ror"]="1010"+to_binary(10,5)+"0";
    oneOperand["rrc"]="1010"+to_binary(11,5)+"0";
    oneOperand["asr"]="1010"+to_binary(12,5)+"0";
    oneOperand["lsl"]="1010"+to_binary(13,5)+"0";
    oneOperand["rol"]="1010"+to_binary(14,5)+"0";
    oneOperand["rlc"]="1010"+to_binary(15,5)+"0";
    twoOperand["mov"] =to_binary(9,4);
    twoOperand["add"] =to_binary(1,4);
    twoOperand["adc"] =to_binary(2,4);
    twoOperand["sub"] =to_binary(0,4);
    twoOperand["sbc"] =to_binary(3,4);
    twoOperand["and"] =to_binary(4,4);
    twoOperand["or"]  =to_binary(5,4);
    twoOperand["xnor"]=to_binary(6,4);
    twoOperand["cmp"] =to_binary(8,4);
    branch["br"] ="1011"+to_binary(0,3)+"0";
    branch["beq"]="1011"+to_binary(1,3)+"0";
    branch["bne"]="1011"+to_binary(2,3)+"0";
    branch["blo"]="1011"+to_binary(3,3)+"0";
    branch["bls"]="1011"+to_binary(4,3)+"0";
    branch["bhi"]="1011"+to_binary(5,3)+"0";
    branch["bhs"]="1011"+to_binary(6,3)+"0";
    others["hlt"]="1100100000000000";
    others["nop"]="1100000000000000";
}
string oneOperand_opcode(string s)
{
    if(oneOperand.count(s)) return oneOperand[s];
    return "";
}
string twoOperand_opcode(string s)
{
    if(twoOperand.count(s)) return twoOperand[s];
    return "";
}
string branch_opcode(string s)
{
    if(branch.count(s)) return branch[s];
    return "";
}
string others_opcode(string s)
{
    if(others.count(s)) return others[s];
    return "";
}
string process(string s)
{
    if(!s.length()) return s;
    int comment = s.find(';');
    if(comment!=-1)
    {
        string ret = s.substr(0,comment);
        if(!ret.length())   return "";
        s = ret;
    }
    int space1=s.find_first_not_of(' '),space2=s.find_last_not_of(' ');
    if(space1!=-1) 
    {
        string ret = s.substr(space1,space2-space1+1);
        if(!ret.length()) return "";
        s = ret;
    }
    string ret="";
    ret+=s[0];
    for(int i=1;i<s.length();i++)   
    {
        if((s[i]==ret.back() && s[i]==' ') || s[i]=='\t')   continue;
        ret+=s[i];
    }
    if(ret[ret.length()-1]==' ' || ret[ret.length()-1]=='\t')    return ret.substr(0,ret.length()-1);
    return ret;
}
pair<string,int> check_mode(string &s)
{   
    if(modes.count(s))   return{modes[s],0};
    int par=s.find('(');
    if(par!=-1) //indexed
    {
        string x="";
        if(s[0]=='@')   //indirect
            x=s.substr(1,par-1),s="@X("+s.substr(par+1,2)+ ")";
        else  //direct
            x=s.substr(0,par),s="X("+s.substr(par+1,2)+ ")";
        return {x,-2};
    }
    string tmp=s;
    //immediate
    if(s[0]=='#')   
    {
        s = "(R7)+";
        return {process(tmp.substr(1)),-2};
    }
    //absolute 2 
    int num = s[0]-'0';
    if(num >=0  && num<10)
    {
        s = "@(R7)+";
        return {tmp , -4};
    }
    //absolute 1
    s = "X(R7)";
    return {tmp,-3};
}

void process_one_operand(string operation,string operand,ofstream&out)
{
    out<<oneOperand[operation]<<modes[operand]<<endl;
}
void process_two_operand(string operation,string operand1,string operand2,ofstream&out)
{
    out<<twoOperand[operation]<<modes[operand1]<<modes[operand2]<<endl;
}
void process_branch_operand(string operation,int offset,ofstream&out)
{
    out<<branch[operation]<<to_binary(offset,8)<<endl;
}
void process_other_operations(string operation,ofstream&out)
{
    out<<others[operation]<<endl;
}
//assumptions 
/*
    -only operations,variables,labels are case insensetive 
    -only variables are detected and assumed to be word size
    -code must be correct(not all errors are defined yet)
*/
int main()
{
    preProcess();
    ifstream in("test.txt");
    ofstream out("output.txt");
    // ofstream op("opcodes.txt");
    // ofstream mem("memory.txt");
    ofstream ram("Ram.txt");
    string s;
    //get adresses
    while(getline(in,s))
    {
        s = process(s);
        if(s=="")   continue;
        bool wasLabel=false;
        //label
        if(s.find(':')!=-1) //label
        {
            commands.push_back({0,{vector<string>(),address}});
            string tmp=s.substr(0,s.find(':'));
            lower(tmp);
            commands[idx++].second.first.push_back(tmp);
            labels[process(tmp)]=address;
            s = s.substr(s.find(':')+1);
            s = process(s);
            if(s=="")   continue;
            wasLabel=true;
        }
        if(wasLabel)    commands.push_back({0,{vector<string>(),address}});
        //operation
        int first_space = s.find_first_of(' ');
        if(first_space==-1) //only one word
        {
            commands.push_back({0,{vector<string>(),address}});
            lower(s);
            if(others_opcode(s)!="")   //(HLT , NOP)
            {
                commands[idx].first=5;
                commands[idx++].second.first.push_back(s);
                address++;
                continue;
            }
            cout<<"Error in hlt and nop"<<endl;
            return 0;
        }
        string operation = s.substr(0,first_space);
        lower(operation);  
        s = s.substr(first_space+1);
        if(operation == "define")   //variable
        {
            s = process(s);
            int second_space = s.find(' ');
            if(second_space==-1)
            {
                cout<<"Error in vars"<<endl;
                return 0;
            }
            string var=s.substr(0,second_space);
            s = process(s.substr(second_space+1));
            lower(var);
            vars[var]={var_address++,stoi(s)};
            vars_to_memory.push_back(to_binary(stoi(s),16));
            continue;
        } 
        commands.push_back({0,{vector<string>(),address}});
        commands[idx].second.first.push_back(operation);         
        int comma = s.find_first_of(',');
        string first_operand = "";
        bool isOneOperand=false;
        if(comma == -1)
            first_operand = s,isOneOperand = true;
        else
            first_operand = s.substr(0,comma),s = s.substr(comma+1);
        first_operand = process(first_operand);
        if(isOneOperand)
        {
            if(oneOperand_opcode(operation)!="")
            {
                pair<string,int> tmp = check_mode(first_operand);
                commands[idx].first=1;
                commands[idx++].second.first.push_back(first_operand);
                if(tmp.second<0)  //special mode
                    commands.push_back({tmp.second,{vector<string>(1,tmp.first),++address}}),idx++;
            }
            else if(branch_opcode(operation)!="")
            {
                lower(first_operand);
                commands[idx].first=4;
                commands[idx++].second.first.push_back(first_operand);
            }
            else
            {
                cout<<"No one operand operation exist or branch"<<endl;
                return 0;
            }
            address++;
            continue;
        }
        s = process(s);
        pair<string,int> op1 = check_mode(first_operand), op2 = check_mode(s);
        commands[idx].first=2;
        commands[idx].second.first.push_back(first_operand);
        commands[idx++].second.first.push_back(s);
        if(op1.second<0)    //special mode
            commands.push_back({op1.second,{vector<string>(1,op1.first),++address}}),idx++;
        if(op2.second<0)    //special mode
            commands.push_back({op2.second,{vector<string>(1,op2.first),++address}}),idx++;
        address++;
    }

    int line = 0;
    //process code
    for(int i=0;i<commands.size();i++)
    {
        out<<commands[i].first<<" ";
        for(int j=0;j<commands[i].second.first.size();j++) out<<commands[i].second.first[j]<<" ";
        out<<commands[i].second.second<<endl;
        int mode=commands[i].first;
        if(mode == 0)   //label
            continue;
        if(mode == 1)   //one operand
            process_one_operand(commands[i].second.first[0],commands[i].second.first[1],ram);
        else if(mode == 2)  //two operand
            process_two_operand(commands[i].second.first[0],commands[i].second.first[1],commands[i].second.first[2],ram);
        else if(mode == 4)
        {
            int cur_address=commands[i].second.second;
            if(!labels.count(commands[i].second.first[1]))
            {
                cout<<"Error label not found\n";
                return 0;
            }
            process_branch_operand(commands[i].second.first[0],labels[commands[i].second.first[1]]-cur_address-1,ram);
        }
        else if(mode == 5)
            process_other_operations(commands[i].second.first[0],ram);
        else if(mode == -3)
        {
            string var=commands[i].second.first[0];
            lower(var);
            if(!vars.count(var))
            {
                cout<<"Error , variable not found"<<endl;
                return 0;
            }
            ram<<to_binary(512 + vars[var].first - commands[i].second.second - 1,16)<<endl;
        }
        else if(mode == -2 || mode == -4)
            ram<<to_binary(stoi(commands[i].second.first[0]),16)<<endl;
        line++;
    }
    while(line < 512)  
    {
        ram << to_binary(0,16)<<endl;
        line++;
    }
    //write variables to memory
    for(auto var:vars_to_memory)
    {
        ram << var <<endl;
        line++;
    }
    while(line<2048)
    {
        ram << to_binary(0,16)<<endl;
        line++;
    }
    // stack pointer at 2047
    // code segment from 0 to 511 , data segment from 512 to 1023 , stack segment from 1024 to 2047
    in.close();
    // op.close();
    // mem.close();
    out.close();
    ram.close();
}
