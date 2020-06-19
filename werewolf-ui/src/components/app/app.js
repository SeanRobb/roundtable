import React from 'react';
import {
  BrowserRouter as Router,
  Switch,
  Route
} from "react-router-dom";
import Home from '../home/home';
import Register from '../register/register';
import Board from '../board/board';
import './app.css';

function App() {
  return (
    <Router>
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
  );
}

function Finish() {
  return <h2>Finish Page</h2>;
}

export default App;
