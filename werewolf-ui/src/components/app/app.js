import React, { useState }  from 'react';
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link,
  NavLink
} from "react-router-dom";
import Home from '../home/home';
import Register from '../register/register';
import Board from '../board/board';
import './app.css';
import {getUsername} from '../../utils/index';
import Player from '../player/player';
import {AppBar, Toolbar,Typography,Avatar, Button, Grid } from '@material-ui/core';  

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
            <Grid item>
              <Grid container>
                <Grid item>
                {/* <Typography variant='h6'>{userName}</Typography>  */}
                </Grid>
              </Grid>
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
            <Route path="/finish" component={Finish} />
            <Route path="/" component={Home} />
          </Switch>
        </div>
      </Router>
    </div>
  );
}

function Finish() {
  return <h2>Finish Page</h2>;
}

export default App;
