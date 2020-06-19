import React from 'react';
import PropTypes from 'prop-types';
import styles from './home.module.css';
import { Button } from '@material-ui/core';
import { useHistory } from "react-router-dom";
import {createGameRoom} from '../../utils/index';

const Home = () => {
const history = useHistory();

return (
  <div className={styles.home} data-testid="home">
    <h2>Home Page Breakout</h2>
    <Button color="primary" onClick={() => {
      createGameRoom().then((data) => history.push('/' + data.gameId + '/board'));
    }}>Create Werewolf Game Room</Button>
  </div>
)
};

Home.propTypes = {};

Home.defaultProps = {};

export default Home;
