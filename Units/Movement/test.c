#include <iostream> 
#include <unordered_map> 
#include <vector> 
#include <set> 
#include <map> 
using namespace std; 
 
typedef pair<int, int> pii; 
 
vector<vector<int>> g; 
vector<int> vis; 
 
vector<int> path; 
 
int main() 
{ 
    int x; 
    unordered_map<int, int> vec; 
    while (cin >> x) { 
        path.push_back(x); 
        vec[x]++; 
    } 
    int n = vec.size(); 
    map<pii, int> um; 
    for (int i = 1; i < path.size(); i++) { 
        um[{path[i - 1], path[i]}] += 1; 
    } 
    if (um.size() != 2 * (n - 1)) { 
        cout << "NO" << endl; 
        return 0; 
    } 
    
    bool flag = true; 
    for (auto x : um) { 
        if (x.second != 1) 
            flag = false; 
        if (um[{x.first.second, x.first.first}] == 0) 
            flag = false; 
    } 
    
    if (flag == true){
        cout << "YES" << std::endl;
    }
    else
        cout << "NO" << std::endl;    

}

