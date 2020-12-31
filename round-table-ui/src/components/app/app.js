import React from 'react';
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link,
} from "react-router-dom";
import Home from '../home/home';
import Register from '../register/register';
import Board from '../board/board';
import './app.css';
import {AppBar, Toolbar,Typography, Grid } from '@material-ui/core';  

function App() {

  return (
    <div>
      <Router>
      <AppBar position="static">  
        <Toolbar>
          <Grid container  justify='space-between'>
            <Grid item>
              <Link style={{ color: 'inherit', textDecoration: 'inherit'}} to="/"><Typography variant="h6">Round Table Games</Typography></Link>
            </Grid>
          </Grid>
        </Toolbar>  
      </AppBar> 
        <div>
          {/* A <Switch> looks through its children <Route>s and
              renders the first one that matches the current URL. */}
          <Switch>
            <Route path="/:game/board" component={Board} />
            <Route path="/register" component={Register} />
            <Route path="/" component={Home} />
          </Switch>
        </div>
      </Router>
    </div>
  );
}

export default App;
