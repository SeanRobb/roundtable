import React from 'react';
import PropTypes from 'prop-types';
import styles from './createGameButton.module.css';
import { Button } from '@material-ui/core';
import { useHistory } from "react-router-dom";
import {createGameRoom} from '../../utils/index';

const CreateGameButton = (props) => {

  const history = useHistory();
  
  return (
  <Button color="primary" className={styles.createGameButton} data-testid="createGameButton"
   onClick={() => {
    createGameRoom(props.type).then((data) => history.push('/' + data.id + '/board'));
  }}>Create Game Room</Button>
)};

CreateGameButton.propTypes = {};

CreateGameButton.defaultProps = {};

export default CreateGameButton;
